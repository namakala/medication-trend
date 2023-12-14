# Functions to report results

describe <- function(ts, type, ...) {
  #' Describe the Time Series
  #'
  #' A wrapper function to perform descriptive statistics in a time-series data
  #'
  #' @param ts A tidy time-series data frame, usually the output of `mergeTS`
  #' function
  #' @param type Type of descriptive analysis to perform
  #' @param ... Parameters to pass on to `describeMean` or `vizPairs`
  #' @return A data frame or GGPlot2 object containing the statistical summary

  if (type == "mean") {
    res <- describeMean(ts, ...)
  } else if (type == "pair") {
    res <- vizPair(ts, ...)
  } else if (type == "polar") {
    res <- vizPolar(ts, ...)
  }

  return(res)
}

describeMean <- function(ts) {
  #' Describe the Mean Difference
  #'
  #' Describe the mean difference beyond certain time point in a time-series
  #' data
  #'
  #' @param ts A tidy time-series data frame, usually the output of `mergeTS`
  #' function
  #' @return A data frame containing the statistical summary

  # Transform the time series into a long-format tibble
  tbl <- ts %>%
    tibble::tibble() %>%
    subset(select = -c(date, neuro_med)) %>%
    tidyr::pivot_longer(eigen:claim2patient)

  # Calculate the mean difference for all metrics before and after 2019
  res <- tbl %>%
    tidyr::nest(data = c(event, value)) %>%
    dplyr::mutate(
      "diff" = purrr::map(data, ~ t.test(value ~ event, data = .x)),
      "tidy_diff" = purrr::map(diff, broom::tidy)
    ) %>%
    tidyr::unnest(tidy_diff) %>%
    subset(select = c(name, group, estimate1, estimate2, estimate, p.value)) %>%
    dplyr::rename(
      p = p.value,
      diff = estimate,
      metric = name,
      covid  = estimate1,
      pre_covid = estimate2
    ) %>%
    dplyr::arrange(metric, group)

  return(res)
}
