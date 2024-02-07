# Functions to perform spectral analysis, especially manipulate objects from `Rssa`

reconSsa <- function(ssa, naive = TRUE, type = "cor", as_tibble = TRUE, ...) {
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

  # Create a tidy data frame
  tbl <- recon %>% unlist() %>%
    matrix(ncol = n_col) %>%
    data.frame() %>%
    tibble::tibble() %>%
    dplyr::rename_with(~ gsub("X", "F", .x)) %>%
    tibble::add_column("Original"  = attr(recon, "series"), .before = 1) %>%
    tibble::add_column("Residuals" = attr(recon, "residuals"), .after = 1) %>%
    tibble::add_column("group"     = ssa_group, .before = 1) %>%
    tibble::add_column("date"      = as.Date(ssa_date), .after  = 1) %>%
    tibble::add_column("metric"    = ssa_metric, .after = 2)

  # Clean up the data frame as tsibble
  tidy_recon <- tbl %>%
    tidyr::pivot_longer(c(Original, Residuals, dplyr::starts_with("F")), names_to = "component") %>%
    dplyr::mutate(
      component = factor(
        component,
        levels = c("Original", paste0("F", 1:n_col), "Residuals")
      )
    ) %>%
    tsibble::as_tsibble(index = date, key = c(group, metric, component))

  return(tidy_recon)
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

