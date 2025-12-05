# Functions to clean the data

setGroupFactor <- function(group) {
  #' Set Group Factor
  #'
  #' Set the level of medication group as a factor
  #'
  #' @param group The medication group variable, containing 25 levels as
  #' indicated by the `groupAtc` function
  #' @return A vector of factors describing the medication group

  res <- factor(group, levels = genLabel())

  return(res)
}

getNeuroMeds <- function() {
  #' Get Nervous System Medications
  #'
  #' This function will take no parameter and generate a list of nervous system
  #' medication, as indicated by code `N0x` by the WHOCC ATC code.
  #'
  #' @return A vector of nervous system medications, including psychopharmaca

  res <- c(
    "Anesthetic",
    "Analgesics",
    "Antiepileptics",
    "Antiparkinson",
    "Antipsychotics",
    "Anxiolytics",
    "Hypnotics and sedatives",
    "Antidepressants",
    "Psychostimulants",
    "Psycholeptics + psychoanaleptics",
    "Antidementia",
    "Other nervous system drugs"
  )

  return(res)
}

genLabel <- function() {
  #' Generate Matrix Label
  #'
  #' Generate label for matrix dimension, the label is set to ATC group name by
  #' default
  #'
  #' @return A vector of character object

  label <- c(
    "Alimentary and metabolism",
    "Blood",
    "Cardiovascular",
    "Dermatologicals",
    "Genitourinary",
    "Systemic hormonal",
    "Systemic anti-infectives",
    "Antineoplastics",
    "Musculoskeletal",
    getNeuroMeds(), # Insert medications for the nervous system
    "Antiparasitics",
    "Respiratory",
    "Sensory",
    "Others"
  )

  return(label)
}

isCovid <- function(x, covid_date = "2020-03-11") {
  #' Annotate COVID-19 Date
  #'
  #' Annotate the date with COVID-19 event as announced by the WHO
  #'
  #' @param x A variable containing dates
  #' @param covid_date A date reference of the time COVID-19 was announced as a
  #' global pandemic
  #' @return A factor of events
  require("tsibble")
  x %<>% as.Date()
  res <- ifelse(x < covid_date, "Pre-COVID-19", "COVID-19") %>%
    factor(levels = c("Pre-COVID-19", "COVID-19"))

  return(res)
}

mergeTS <- function(tbl_metrics, tbl_stats, covid_date = "2020-03-11", ...) {
  #' Merge Time Series Data
  #'
  #' Get the time-series data frame by combining graph-object centrality
  #' metrics from `getMetrics` and group-wise descriptive statistics from
  #' `fieldSummary`. The group-wise descriptive statistics table is expected to
  #' contain `NA` due to absence of medication claim for a particular group.
  #' To keep the consistency, this `NA` values are imputed with 0.
  #'
  #' @param tbl_metrics A data frame containing node names and its metrics
  #' @param tbl_stats An aggregate data frame summarizing the number of daily
  #' claims for each medication group
  #' @param covid_date Announced date of COVID-19 as a global pandemic
  #' @param ... Parameters to pass on to `aggregateTS`
  #' @return A tidy time-series data frame combining graph's metrics and the
  #' field summary

  tbl <- merge(tbl_metrics, tbl_stats, all.x = TRUE) %>%
    tibble::tibble()

  # Clean the dataset
  tbl_clean <- tbl %>%
    inset2("group", value = setGroupFactor(.$group)) %>% # Set factor
    inset2("neuro_med", value = .$group %in% getNeuroMeds()) %>% # Neuro meds
    inset2("event", value = isCovid(.$date, covid_date = covid_date)) %>%
    inset( # Replace `NA` with 0
      c("n_claim", "claim2patient"),
      value = list(
        .$n_claim       %>% replace(is.na(.), 0),
        .$claim2patient %>% replace(is.na(.), 0)
      )
    ) %>% # Exclude uninformative group
    subset(
      .$group != "Psycholeptics + psychoanaleptics" &
      .$date  >= "2018-01-01" &
      .$date  <= "2022-12-31"
    )

  if (hasArg("type")) {
    ts <- tbl_clean %>% aggregateTS(...)
    return(ts)
  }
  
  # Return as a time series
  ts <- tbl_clean %>% tsibble::as_tsibble(key = group, index = date)

  return(ts)
}

aggregateTS <- function(ts, type = "week", ...) {
  #' Aggregate Time Series
  #'
  #' Aggregate time-series data into week, month, or quarter
  #'
  #' @param ts A tidy time-series data frame, usually the returned value of
  #' `mergeTS`. Could also be a data frame containing `index` (and optionally
  #' `key`) to generate a `tsibble`.
  #' @param type Type of aggregation, supporting either `week`, `month`, or
  #' `quarter`
  #' @return A tidy time-series data with aggregated metrics

  if (type == "week") {
    ts %<>% inset2("date", value = tsibble::yearweek(.$date))
  } else if (type == "month") {
    ts %<>% inset2("date", value = tsibble::yearmonth(.$date))
  } else if (type == "quarter") {
    ts %<>% inset2("date", value = tsibble::yearquarter(.$date))
  } else {
    warning("Returning time-series of daily records")
    ts %<>% tsibble::as_tsibble(key = group, index = date)
    return(ts)
  }

  ts %<>% tibble::tibble()

  ts_agg <- ts %>%
    dplyr::group_by(group, date) %>%
    dplyr::summarize(
      "date"          = min(date),
      "eigen"         = mean(eigen, na.rm = TRUE),
      "pagerank"      = mean(pagerank, na.rm = TRUE),
      "degree"        = sum(degree, na.rm = TRUE),
      "strength"      = sum(strength, na.rm = TRUE),
      "n_claim"       = sum(n_claim, na.rm = TRUE),
      "n_patient"     = sum(n_patient, na.rm = TRUE),
      "claim2patient" = sum(n_claim, na.rm = TRUE) / sum(n_patient, na.rm = TRUE),
      "neuro_med"     = all(neuro_med),
      "event"         = table(event) |> sort() |> names() |> tail(1)
    ) %>%
    dplyr::ungroup() %>%
    tsibble::as_tsibble(key = group, index = date)

  return(ts_agg)
}

checkDose <- function(atc_tbl) {
  #' Check Dose
  #'
  #' Check the dose to exclude entries with high DDD but low period of
  #' prescription. For instance, the use of intrauterine device would span over
  #' five years, but only prescribed for a day. This will result in an entry
  #' with DDD = 1,800. This function checks whether the entry can be directly
  #' analyze.
  #' 
  #' @param atc_tbl A data frame containing split ATC entries
  #' @return A vector of boolean indicating which entry is eligible to analyze

  startdat <- as.Date(atc_tbl$date)
  stopdat  <- as.Date(atc_tbl$end)
  dose     <- as.numeric(atc_tbl$dose)
  eligible <- {dose / as.numeric(stopdat - startdat)} <= 1

  return(eligible)
}

cleanDose <- function(atc_tbl, period = NULL) {
  #' Clean Dose
  #'
  #' Clean the dose to regularie entries with DDD > 1.
  #'
  #' @param atc_tbl A data frame containing split ATC entries
  #' @param period Period of use, usually `stopdat` - `startdat`
  #' @return A split ATC data frame containing entries with cleaned doses

  is_arr <- is.null(dim(atc_tbl)) # Check if array

  if (is_arr) {

    if (is.null(period)) {
      stop("Period of use should be set using the `period` argument for an array object")
    }

    dose <- atc_tbl

    res <- ifelse(dose <= 1, dose, dose / period)

  } else {

    startdat <- as.Date(atc_tbl$date)
    stopdat  <- as.Date(atc_tbl$end)
    period   <- as.numeric(stopdat - startdat)

    res <- atc_tbl |>
      dplyr::mutate(
        ".dose" = dose,
        "dose"  = cleanDose(atc_tbl$dose, period)
      )

  }

  return(res)
}

combineSubgroup <- function(tbl_list) {
  #' Combine Subgroup
  #'
  #' Combine time-series data frame obtained from subgroup analyses.
  #'
  #' @param tbl_list A named list containing similarly constructed data frame
  #' @return A concatenated data frame for visualization

  res <- names(tbl_list) |>
    lapply(\(id) {
      sub_tbl <- tbl_list[[id]] |>
        tibble::tibble() |>
        dplyr::select(date, group, eigen, n_claim, hi_eigen) |>
        dplyr::mutate("sub" = id)
      return(sub_tbl)
    }) %>%
    {do.call(rbind, .)}

  return(res)
}
