# Functions to clean the data

setGroupFactor <- function(group) {
  #' Set Group Factor
  #'
  #' Set the level of medication group as a factor
  #'
  #' @param group The medication group variable, containing 25 levels as
  #' indicated by the `groupAtc` function
  #' @return A vector of factors describing the medication group
  res <- factor(
    group,
    levels = c(
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
  )

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

mergeTS <- function(tbl_metrics, tbl_stats) {
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
  #' @return A tidy time-series data frame combining graph's metrics and the
  #' field summary
  tbl <- merge(tbl_metrics, tbl_stats, all.x = TRUE) %>%
    tibble::tibble()

  # Clean the dataset
  tbl_clean <- tbl %>%
    inset2("group", value = setGroupFactor(.$group)) %>% # Set factor
    inset2("neuro_med", value = .$group %in% getNeuroMeds()) %>% # Neuro meds
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
  
  # Return as a time series
  ts <- tbl_clean %>% tsibble::as_tsibble(key = group, index = date)

  return(ts)
}
