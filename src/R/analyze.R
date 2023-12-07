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

timeDecomp <- function(ts, varname, period, method, ...) {
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

    decomp <- ts %>%
      fabletools::model(feasts::classical_decomposition(
        form, ...
      )) %>%
        fabletools::components()

  } else if (method == "loess") {

    decomp <- ts %>%
      fabletools::model(feasts::STL(
        form, iteration = 10
      )) %>%
        fabletools::components()

  }

  return(decomp)
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
  if (is.vector(ts)) {
    pad     <- rep(NA, n)
    ts_diff <- c(pad, diff(ts, differences = n, ...))
  } else {
    ts_diff <- ts %>%
      dplyr::group_by(group) %>%
      dplyr::mutate(
        eigen         = timeDiff(eigen, n = n, ...),
        pagerank      = timeDiff(pagerank, n = n, ...),
        n_claim       = timeDiff(n_claim, n = n, ...),
        n_patient     = timeDiff(n_patient, n = n, ...),
        claim2patient = timeDiff(claim2patient, n = n, ...)
      ) %>%
      dplyr::ungroup()
  }

  return(ts_diff)
}

fitModel <- function(ts, groupname, y, type = "arima", ...) {
  #' Fit Time-Series Model
  #'
  #' Fit a model to explain or forecast time-series data frame
  #'
  #' @param ts A tidy time-series data frame
  #' @param groupname The name of medication group to subset the data
  #' @param y Metrics to evaluate
  #' @param type The type of model to fit
  #' @param ... Parameters to specify the model
  #' @return A model object
  sub_ts <- ts %>% subset(.$group == groupname, select = y)
  if (type == "arima") {
    mod <- sub_ts %>% forecast::auto.arima(...)
  }

  return(mod)
}
