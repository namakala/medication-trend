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

timeDecomp <- function(ts, varname, group, period, method, ...) {
  #' Time Series Decomposition
  #'
  #' An extended wrapper for `stats::decompose` and `stats::stl`, conveniently
  #' called by `feasts::classical_decomposition` and `feasts::STL`. This
  #' function will also transform the tidy tibble into tsibble.
  #'
  #' @param ts A time series data, usually resulting form the `mergeTS` function
  #' @param varname A variable name indicating the time series to decompose
  #' @param group The grouping variable to subset data
  #' @param period Period of time when calculating the moving average or LOESS
  #' @param method Method of decomposition, only accepts `classic` (moving
  #' average) and `loess` (LOESS)
  #' @inheritDotParams feasts::classical_decomposition
  #' @return A decomposed time-series object
  require("feasts")

  form <- sprintf("%s ~ season(period = '%s')", varname, period) %>% as.formula()
  sub_ts <- ts %>% subset(.$group == group)

  if (method == "classic") {

    decomp <- sub_ts %>%
      fabletools::model(feasts::classical_decomposition(
        form, ...
      )) %>%
        fabletools::components()

  } else if (method == "loess") {

    decomp <- sub_ts %>%
      fabletools::model(feasts::STL(
        form, iteration = 10
      )) %>%
        fabletools::components()

  }

  return(decomp)
}
