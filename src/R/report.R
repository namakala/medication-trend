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

  days <- c(
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  )

  tbl <- tbl_concat |>
    dplyr::filter(date >= "2018-01-01", date <= "2022-12-31") |>
    dplyr::mutate(
      "date" = as.Date(date),
      "day"  = weekdays(date) |> factor(levels = days),
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

mergeReconSummary <- function(ts_recon, res_tbl_stat) {
  #' Merge Reconstructed Data Summary
  #'
  #' Summarize the reconstructed time series, then merge it into
  #' `res_tbl_stat`.
  #'
  #' @param ts_recon The reconstructed data frame
  #' @param res_tbl_stat A summary of the dataset, containing number of unique
  #' patients, dose, and weight
  #' @return A tidy data frame

  ts_stat <- ts_recon |>
    tibble::tibble() |>
    dplyr::group_by(group) |>
    dplyr::summarize(
      "eigen_mean"   = mean(eigen),
      "eigen_sd"     = sd(eigen),
      "eigen_median" = median(eigen),
      "eigen_IQR"    = IQR(eigen),
      "eigen_lo"     = eigen_mean - 1.96 * eigen_sd / sqrt(dplyr::n()),
      "eigen_hi"     = eigen_mean + 1.96 * eigen_sd / sqrt(dplyr::n())
    )

  tbl <- dplyr::inner_join(res_tbl_stat, ts_stat, by = "group")

  return(tbl)
}

detectPolypharmacy <- function(atc_entry, medication = "antidepressants", type = "all") {
  #' Detect Polypharmacy
  #'
  #' Detect the presence of psychiatric polypharmacy as categorized by
  #' @Shrivastava2013. Same-class polypharmacy is the use of multiple
  #' medications from the same class. Multi-class polypharmacy is the use of
  #' multiple medications from different classes indicated for the same symptom
  #' cluster. Adjunctive polypharmacy is the use of additional medications to
  #' treat side effects due to other medications. Augmentation polypharmacy is
  #' the use of full-dose and sub-dose medications from a different class for
  #' the same symptom cluster. Finally, total polypharmacy is the total count
  #' of all medications used by a patient, both psychopharmaca and other
  #' classes alike.
  #'
  #' @param atc_entry Single ATC entry from the raw IADB dataset
  #' @param medication Medication group to use as a reference to detect
  #' polypharmacy
  #' @param type The type of polypharmacy
  #' @return A data frame enumerating same-class, multi-class, and total polypharmacy

  # Clean and list all the ATC codes
  atc_list <- strsplit(atc_entry, split = ",") |>
    lapply(\(atc) gsub(x = atc, ";.*", "")) |>
    unlist()

  # Create a regex reference to categorize polypharmacy
  ref <- switch(
    stringr::str_to_lower(medication),
    "antidepressants" = "^N06A",
    "anxiolytics" = "^N05B"
  )

  same_class  <- grepl(x = atc_list, ref)
  multi_class <- {!same_class} & grepl(x = atc_list, "^N")

  # Detect and categorize polypharmacy
  polypharmacy <- data.frame(
    "same"  = sum(same_class)  %>% {ifelse(. > 0, . - 1, .)},
    "multi" = sum(multi_class) %>% {ifelse(. > 0, . - 1, .)},
    "total" = length(atc_list)
  )

  res <- switch(
    type,
    "same"  = polypharmacy$same,
    "multi" = polypharmacy$multi,
    "total" = polypharmacy$total,
    "all"   = polypharmacy
  )

  return(res)
}

summarizePolypharmacy <- function(sub_tbl_iadb, ...) {
  #' Summarize Polypharmacy
  #'
  #' Generate a summary statistics of detected polypharmacy.
  #'
  #' @param sub_tbl_iadb A subset of IADB table containing only entries listing
  #' anxiolytics or antidepressants
  #' @param ... Parameters being passed on to `detectPolypharmacy`
  #' @return A tidy data frame of the summary statistics

  # Detect polypharmacy for each ATC entry
  tbl <- with(
    sub_tbl_iadb,
    lapply(atcs, \(atc_entry) detectPolypharmacy(atc_entry, type = "all", ...))
  ) %>%
    {do.call(rbind, .)}

  # Iterate the summary statistics functions
  FUNS  <- list(
    "sum"    = sum,
    "mean"   = mean,
    "sd"     = sd,
    "median" = median,
    "IQR"    = IQR,
    "min"    = min,
    "max"    = max
  )

  stats <- lapply(FUNS, function(FUN) {
    aggregate(cbind(same, multi, total) ~ 0, data = tbl, FUN = FUN) |> t()
  })

  # Generate the summary statistics
  tbl_poly_stat <- do.call(cbind, stats) |>
    set_colnames(names(FUNS)) |>
    data.frame() %>%
    tibble::add_column("type" = rownames(.), .before = 1) |>
    tibble::tibble()

  return(tbl_poly_stat)
}
