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

summarizeStat <- function(tbl_concat) {
  #' Describe the Summary Statistics
  #'
  #' Calculate summary statistics from a given arrow dataset.
  #'
  #' @param tbl_concat An arrow dataset containing the whole IADB entries
  #' @return A tidy summary statistics table

  tbl <- tbl_concat %>% dplyr::filter(date >= "2018-01-01", date <= "2022-12-31")

  res <- tbl %>%
    dplyr::group_by(group) %>%
    dplyr::summarize(
      "n_claim"       = sum(n, na.rm = TRUE),
      "dose_mean"     = mean(dose, na.rm = TRUE),
      "dose_sd"       = sd(dose, na.rm = TRUE),
      "dose_median"   = median(dose, na.rm = TRUE),
      "dose_IQR"      = IQR(dose, na.rm = TRUE),
      "dose_min"      = min(dose, na.rm = TRUE),
      "dose_max"      = max(dose, na.rm = TRUE),
      "weight_mean"   = mean(weight, na.rm = TRUE),
      "weight_sd"     = sd(weight, na.rm = TRUE),
      "weight_median" = median(weight, na.rm = TRUE),
      "weight_IQR"    = IQR(weight, na.rm = TRUE),
      "weight_min"    = min(weight, na.rm = TRUE),
      "weight_max"    = max(weight, na.rm = TRUE)
    ) %>%
    dplyr::ungroup() %>%
    dplyr::collect()

  return(res)
}

overviewData <- function(tbl_concat) {
  #' Overview Data
  #'
  #' Create a descriptive overview of the data.
  #'
  #' @param tbl_concat An arrow dataset containing the whole IADB entries
  #' @return A tidy descriptive overview table
  require("tsibble")

  tbl <- tbl_concat |>
    dplyr::filter(date >= "2018-01-01", date <= "2022-12-31") |>
    dplyr::mutate(
      "date" = as.Date(date),
      "day"  = weekdays(date),
      "week" = tsibble::yearweek(date)
    )

  total <- tbl$id |> unique() |> length()

  overview <- tbl |>
    dplyr::group_by(week, day) |>
    dplyr::summarize("n_claim" = unique(id) |> length()) |>
    dplyr::group_by(day) |>
    dplyr::summarize(
      "mean_claim"   = mean(n_claim, na.rm = TRUE),
      "sd_claim"     = sd(n_claim, na.rm = TRUE),
      "median_claim" = median(n_claim, na.rm = TRUE),
      "IQR_claim"    = IQR(n_claim, na.rm = TRUE),
      "min_claim"    = min(n_claim, na.rm = TRUE),
      "max_claim"    = max(n_claim, na.rm = TRUE)
    ) |>
    dplyr::ungroup()

  res <- list("total" = total, "overview" = overview)

  return(res)
}

