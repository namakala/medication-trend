# Functions to analyze the tabular data

fieldSummary <- function(tbl) {
  #' Summary of Multiple Fields
  #'
  #' Calculate descriptive statistical summary using several fields. This
  #' function takes a split ATC data frame as its input, which is already
  #' grouped per day.
  #'
  #' @param tbl Split ATC data frame
  #' @return An aggregate data frame
  res <- tbl %>%
    dplyr::group_by(group) %>%
    dplyr::summarize(
      "n_claim"       = sum(n),
      "n_patient"     = unique(id) %>% length(),
      "claim2patient" = sum(n) / length(unique(id))
    ) %>%
    data.frame() # To preserve row number when binding the rows

  return(res)
}

timeDecom <- function(ts, varname, period, method, ...) {
  #' Time Series Decomposition
  #'
  #' An extended wrapper for `stats::decompose` and `stats::stl`, conveniently
  #' called by `feasts::classical_decomposition` and `feasts::STL`. This
  #' function will also transform the tidy tibble into tsibble.
  #'
  #' @param ts A time series data, usually resulting form the `mergeTS` function
  #' @param varname A variable name indicating the time series to decompose
  #' @param period Period of time when calculating the moving average or LOESS
  #' @param method Method of decomposition, only accepts `classic` (moving
  #' average) and `loess` (LOESS)
  #' @inheritDotParams feasts::classical_decomposition
  #' @return A decomposed time-series object
  require("feasts")

  form <- sprintf("%s ~ season(period = '%s')", varname, period) %>% as.formula()

  if (method == "classic") {

    decom <- ts %>%
      fabletools::model(feasts::classical_decomposition(
        form, ...
      )) %>%
        fabletools::components()

  } else if (method == "loess") {

    decom <- ts %>%
      fabletools::model(feasts::STL(
        form, iteration = 10
      )) %>%
        fabletools::components()

  }

  return(decom)
}

timeDiff <- function(ts, n = 1, ...) {
  #' Time-Series Differencing
  #'
  #' Perform n-order time-series differencing
  #'
  #' @param ts A tidy time series data frame, usually the output of `mergeTS`
  #' @param n Order of differences
  #' @inheritDotParams base::diff
  #' @return A tidy time-series data frame
  require("tsibble")

  if (is.vector(ts)) {
    pad     <- rep(NA, n)
    ts_diff <- c(pad, diff(ts, differences = n, ...))
  } else {
    ts_diff <- ts %>%
      dplyr::group_by(group) %>%
      dplyr::mutate(
        eigen         = timeDiff(eigen, n = n, ...),
        pagerank      = timeDiff(pagerank, n = n, ...),
        degree        = timeDiff(degree, n = n, ...),
        strength      = timeDiff(strength, n = n, ...),
        n_claim       = timeDiff(n_claim, n = n, ...),
        n_patient     = timeDiff(n_patient, n = n, ...),
        claim2patient = timeDiff(claim2patient, n = n, ...)
      ) %>%
      dplyr::ungroup()
  }

  return(ts_diff)
}

evalUnitRoot <- function(ts, y, summarize = TRUE) {
  #' Calculate the Augmented Dickey-Fuller Test
  #'
  #' Test for stationarity using the ADF test. Stationary time-series will have
  #' a significant p-value.
  #'
  #' @param ts A time-series data
  #' @param y Metrics to evaluate
  #' @param summarize A boolean to return only the summary of time-series
  #' presenting with non-stationarity
  #' @return A tidy data frame containing the results of the ADF test

  meds <- ts$group %>% unique() %>% set_names(., .)
  res  <- lapply(meds, function(med) {
    ts %>%
      subset(.$group == med) %>%
      extract2(y) %>%
      na.omit() %>%
      tseries::pp.test() %>% # Calculate the Phillips-Perron test
      broom::tidy() %>%
      data.frame()
  }) %>%
    {do.call(rbind, .)} %>% # Combining all results
    inset2("group", value = rownames(.)) %>%
    inset2("metric", value = y) %>%
    tibble::tibble()

  if (summarize) {
    res %<>% subset(.$p.value >= 0.05, select = c(group, metric))
  }

  return(res)
}

