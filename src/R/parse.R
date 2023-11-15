# Functions to parse the dataset

lsData <- function(path = "data/raw", ...) {
  #' List Data
  #'
  #' List all data file within `path` directory
  #'
  #' @param path A path of raw data directory, set to "data/raw" by default
  #' @return A list of complete relative path of each dataset
  filepath <- list.files(path, full.name = TRUE, recursive = TRUE, ...) %>%
    set_names(gsub(x = ., ".*_|\\.\\w*", ""))

  return(filepath)
}

readIADB <- function(filepath, ...) {
  #' Read IADB
  #'
  #' Read IADB dataset as a tibble using vroom
  #'
  #' @param filepath The complete path of the data
  #' @inheritDotParams vroom::vroom
  #' @return An indexed tibble data frame
  tbl <- vroom::vroom(filepath, delim = ";", ...) %>%
    tibble::add_column(
      "month" = format(.$startdat, "%m"),
      "year"  = format(.$startdat, "%y")
    )
  
  return(tbl)
}

groupAtc <- function(atc_list) {
  #' Categorize ATC Code
  #'
  #' Categorize the ATC code based on WHOCC aggregation groups. For
  #' ATCs in N group, the second level of aggregation is used. For other
  #' medications, the first level of aggregation is used.
  #'
  #' @param atc_list List of multiple ATC entries for a subject for each
  #' recorded date
  #' @return extended list of ATC including its corresponding grouping variable
  atc_group <- atc_list$label %>%
    {dplyr::case_when(
      grepl(x = ., "^A")    ~ "Alimentary and metabolism",
      grepl(x = ., "^B")    ~ "Blood",
      grepl(x = ., "^C")    ~ "Cardiovascular",
      grepl(x = ., "^D")    ~ "Dermatologicals",
      grepl(x = ., "^G")    ~ "Genitourinary",
      grepl(x = ., "^H")    ~ "Systemic hormonal",
      grepl(x = ., "^J")    ~ "Systemic anti-infectives",
      grepl(x = ., "^L")    ~ "Antineoplastics",
      grepl(x = ., "^M")    ~ "Musculoskeletal",
      grepl(x = ., "^N01")  ~ "Anesthetic",
      grepl(x = ., "^N02")  ~ "Analgesics",
      grepl(x = ., "^N03")  ~ "Antiepileptics",
      grepl(x = ., "^N04")  ~ "Antiparkinson",
      grepl(x = ., "^N05A") ~ "Antipsychotics",
      grepl(x = ., "^N05B") ~ "Anxiolytics",
      grepl(x = ., "^N05C") ~ "Hypnotics and sedatives",
      grepl(x = ., "^N06A") ~ "Antidepressants",
      grepl(x = ., "^N06B") ~ "Psychostimulants",
      grepl(x = ., "^N06C") ~ "Psycholeptics + psychoanaleptics",
      grepl(x = ., "^N06D") ~ "Antidementia",
      grepl(x = ., "^N07")  ~ "Other nervous system drugs",
      grepl(x = ., "^P")    ~ "Antiparasitics",
      grepl(x = ., "^R")    ~ "Respiratory",
      grepl(x = ., "^S")    ~ "Sensory",
      grepl(x = ., "^V")    ~ "Others",
      .default = "Others"
    )}

  atc_list %<>% tibble::add_column("group" = atc_group, .after = 1)

  return(atc_list)
}

splitAtc <- function(tbl, atcs) {
  #' Split ATC Fields
  #'
  #' Split included ATC fields from the IADB dataset. The field should be
  #' formatted as `atc_code n ddd_day`, where `atc_code` is the corresponding
  #' ATC code according to WHOCC classification, `n` is the defined daily
  #' dose prescirbed, and `ddd_day` is a static string. The field may contain
  #' multiple ATC codes, separated by comma.
  #'
  #' @param tbl IADB data frame
  #' @param atcs A character vector indicating the ATC variable name
  #' @return A tibble containing multiple ATC entries for each recorded date

  # Calculate unique patients within the dataset
  N <- unique(tbl$anopat) %>% length()

  # Iterate through a vector of combined ATCs
  atc_tbls <- apply(tbl, 1, function(entry) {
    anopat   <- entry[1]
    startdat <- entry[2]
    atc      <- entry[4]

    atc   %<>% as.character() %>% strsplit(split = ",") %>% unlist()
    label  <- gsub(x = atc, ";.*", "")
    dose   <- atc %>%
      {gsub(x = ., ".*;|\\s.+", "")} %>%
      as.numeric()

    tbl <- tibble::tibble(
      label, dose, "n" = 1, "N" = N, "id" = anopat, "date" = startdat
    ) %>%
      groupAtc() %>%
      subset(.$label != "")

    return(tbl)
  })

  atc_tbl <- do.call(rbind, atc_tbls)
  
  return(atc_tbl)
}

iterby <- function(tbl, varname, FUN, ...) {
  #' Iterate Through A Variable
  #'
  #' Iterate a function through rows of data frame grouped by a variable
  #'
  #' @param tbl A data frame containing `varname` and column of interest to
  #' pass on to `FUN`
  #' @param varname A variable to group each row of the data frame
  #' @param FUN A function to call for each subsequent row when the data frame
  #' is grouped by `varname`
  #' @return A processed data frame
  groups <- tbl[[varname]] %>% unique() %>% sort() %>% set_names(., .)

  proc_group <- lapply(groups, function(group) {
    sub_tbl <- tbl %>% subset(.[[varname]] == group)
    FUN(sub_tbl, ...)
  })

  return(proc_group)
}
