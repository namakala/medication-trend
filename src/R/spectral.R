# Functions to perform spectral analysis, especially manipulate objects from `Rssa`

reconSsa <- function(ssa, naive = TRUE, type = "wcor", as_tibble = TRUE, ...) {
  #' Reconstruct SSA Decomposition
  #'
  #' Reconstruct the SSA model to obtain its constituting functions
  #'
  #' @param ssa An SSA model, usually obtained from `fitSsa`
  #' @param naive A boolean to indicate extracting a naive reconstruction, i.e.
  #' no prior assumption on groupings
  #' @param type Type of SSA group to extract, support either `pgram`, `wcor`,
  #' or `cor`. This argument is passed on to `getSsaGroup` when `naive` is
  #' `FALSE`.
  #' @param as_tibble A boolean to indicate return as a tibble
  #' @inheritDotParams Rssa::reconstruct
  #' @return A reconstructed time-series data
  require("Rssa")

  # Reconstruct the time-series
  if (naive) {
    recon  <- Rssa::reconstruct(ssa, ...) # Without groupings
  } else { # With automatic groupings
    groups <- getSsaGroup(ssa, type = type, ...)
    recon  <- Rssa::reconstruct(ssa, groups = groups, ...)
  }

  # Insert custom attributes
  attributes(recon)$group  <- attr(ssa, "group")
  attributes(recon)$date   <- attr(ssa, "date")
  attributes(recon)$metric <- attr(ssa, "metric")

  # Inserting trend from a sequential model
  trend  <- attr(ssa, "trend")
  series <- attr(ssa, "series")

  if (!is.null(trend)) {
    attributes(recon)$trend <- trend
  }

  if (!is.null(series)) {
    attributes(recon)$series <- series
  }

  # Return either tibble or the original reconstructed time-series
  if (as_tibble) {
    recon %<>% tidyReconSsa()
  }

  return(recon)
}

tidyReconSsa <- function(recon) {
  #' Tidying Reconstructed Time-Series
  #'
  #' Create a tidy data frame for reconstructed time-series object obtained
  #' from the SSA model
  #'
  #' @param recon
  #' @return A tidy reconstructed time-series
  require("tsibble")

  # Get the total length of the recon object
  n_col <- length(recon)

  # Extract attributes
  ssa_group  <- attr(recon, "group")
  ssa_date   <- attr(recon, "date")
  ssa_metric <- attr(recon, "metric")
  trend      <- attr(recon, "trend")

  # Create a tidy data frame
  tbl <- recon %>% unlist() %>%
    matrix(ncol = n_col) %>%
    data.frame() %>%
    tibble::tibble() %>%
    dplyr::rename_with(~ gsub("X", "F", .x)) %>%
    tibble::add_column("Original"  = attr(recon, "series"), .before = 1) %>%
    tibble::add_column("Residuals" = attr(recon, "residuals"), .after = 1)

  # Insert the previously fitted trend; only available with sequential method
  if (!is.null(trend)) {
    tbl %<>% tibble::add_column("Trend" = trend, .after = 1)
  }

  # Clean up the data frame as tsibble
  if (!{is.null(ssa_group) | is.null(ssa_date) | is.null(ssa_metric)}) {
    tidy_recon <- tbl %>%
      tibble::add_column("group"  = ssa_group, .before = 1) %>%
      tibble::add_column("date"   = as.Date(ssa_date), .before = 1) %>%
      tibble::add_column("metric" = ssa_metric, .before = 1) %>%
      tsReconSsa(n_col)
  } else {
    tidy_recon <- tbl
  }

  return(tidy_recon)
}

tsReconSsa <- function(tidy_recon, n_col) {
  #' Tidy Reconstructed Time Series
  #'
  #' Create a tidy time series from a reconstructed SSA model
  #'
  #' @param tidy_recon A tidy data frame containing reconstructed components
  #' @param n_col The number of reconstructed time series
  #' @return A tsibble of tidy reconstructed time series
  require("tsibble")

  if ("Trend" %in% colnames(tidy_recon)) {
    tbl_long <- tidy_recon %>%
      tidyr::pivot_longer(c(Original, Trend, Residuals, dplyr::starts_with("F")), names_to = "component")
  } else {
    tbl_long <- tidy_recon %>%
      tidyr::pivot_longer(c(Original, Residuals, dplyr::starts_with("F")), names_to = "component")
  }

  ts <- tbl_long %>%
    dplyr::mutate(
      component = factor(
        component,
        levels = c("Original", "Trend", paste0("F", 1:n_col), "Residuals")
      )
    ) %>%
    tsibble::as_tsibble(index = date, key = c(group, metric, component))

  return(ts)
}

getSsaGroup <- function(ssa, type = "cor", ...) {
  #' Extract SSA Groupings
  #'
  #' Extract SSA groupings automatically based on periodogram or correlation
  #' clusters
  #'
  #' @param ssa An SSA model, usually obtained from `fitSsa`
  #' @param type Type of SSA group to extract, support either `pgram`, `wcor`,
  #' or `cor`
  #' @inheritDotParams Rssa::grouping.auto
  require("Rssa")

  if (type == "cor") {

    naive  <- Rssa::reconstruct(ssa) # Avoid calling `reconSsa` to prevent cyclical call in targets
    n_col  <- length(naive)
    mtx    <- unlist(naive) %>% matrix(ncol = n_col) %>% cor(use = "complete.obs")
    groups <- apply(mtx, 1, \(x) which(abs(x) > 0.5), simplify = FALSE) %>%
      unique()

  } else if (type == "wcor") {

    groups <- Rssa::grouping.auto.wcor(ssa, ...)

  } else if (type == "pgram") {

    groups <- Rssa::grouping.auto.pgram(ssa, ...)

  } else {

    stop("Type is not supported, choose only `pgram`, `wcor`, or `cor`")

  }

  return(groups)
}

bindReconSsa <- function(ts_list) {
  #' Bind Reconstructed Time Series
  #'
  #' Bind a list of reconstructed time series into one tsibble
  #'
  #' @param ts_list A list of reconstructed time series, usually the output of
  #' `tsReconSsa`
  #' @return A tidy data frame
  require("tsibble")

  recurse <- "list" %in% lapply(ts_list, class)

  if (recurse) {
    tbl <- lapply(ts_list, bindReconSsa) %>% bindReconSsa()
    return(tbl)
  }

  tbl <- ts_list %>%
    {do.call(dplyr::bind_rows, .)}
    
  return(tbl)
}

genReconTs <- function(tbl, n = 2, detrend = FALSE, widen = TRUE) {
  #' Generate Reconstructed Time Series
  #'
  #' Generate a reconstructed time series based on trend and n number of
  #' oscillating functions
  #'
  #' @param tbl The bound reconstructed time series, usually the output of
  #' `bindReconSsa`
  #' @param n The number of n oscillating functions to use. The more
  #' oscillating functions to use, the close it gets to the original data.
  #' Using all the oscillating functions will recreate the original data, which
  #' means re-introducing the white noises. Keep the n number low, preferably n
  #' = 2.
  #' @param detrend A boolean indicating whether to return a detrended series
  #' or not
  #' @param widen Will return a wide table when set to `TRUE`
  #' @return A tidy time series
  require("tsibble")

  # Generate id for subsetting the dataset
  trend <- tbl$component == "Trend"

  if (n > 0) {
    com <- tbl$component %in% paste0("F", 1:n)
  } else {
    com <- rep(FALSE, times = length(trend))
  }

  if (detrend) {
    if (n < 1) {
      stop("The number of oscillating function (n) should be at least 1 to return detrended data")
    }
    id <- com
  } else {
    id <- trend | com
  }

  tbl %<>%
    tsibble::as_tibble() %>%
    subset(id) %>%
    dplyr::group_by(metric, date, group) %>%
    dplyr::summarize("value" = sum(value)) %>%
    dplyr::ungroup()

  if (widen) {
    tbl %<>% tidyr::pivot_wider(names_from = metric, values_from = value)
  }

  ts <- tbl %>% tsibble::as_tsibble(key = group, index = date)

  return(ts)
}
