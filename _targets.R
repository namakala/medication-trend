# Load packages
pkgs <- c("magrittr", "targets", "tarchetypes", "crew")
pkgs_load <- sapply(pkgs, library, character.only = TRUE)

# Source user-defined functions
funs <- list.files("src/R", pattern = "*.R", full.name = TRUE) %>%
  lapply(source)

# Set options for targets
tar_option_set(
  error      = "continue",
  controller = crew_controller_local(workers = 4), # Enable parallel processing
  storage    = "worker",
  retrieval  = "worker",
  memory     = "transient", # Free up superfluous data
  garbage_collection = TRUE
)

# Set paths for the raw data
iadb_raw <- lsData(pattern = "iadb")

# Switcher for testing or production
is_test <- FALSE
iadb    <- ifelse(is_test, iadb_raw[[1]], iadb_raw[[2]])

# Set the analysis pipeline
list(

  # Read the dataset then group by date
  tar_target(tbl_iadb, readIADB(iadb), format = "fst_tbl"),
  tar_group_select(tbl_iadb_by_date, tbl_iadb, by = c("month", "year")),

  # Split ATC in each grouped data frame
  tar_target(
    tbl_iadb_split_atc,
    iterby(tbl_iadb_by_date, "startdat", splitAtc, "atcs"),
    pattern   = map(tbl_iadb_by_date),
    iteration = "vector"
  ),

  # Generate graph objects from the split ATC data frame
  tar_target(
    iadb_graph,
    lapply(tbl_iadb_split_atc, mkGraph),
    pattern   = map(tbl_iadb_split_atc),
    iteration = "list",
    priority  = 0
  ),

  # Calculate metrics for the graph objects
  tar_target(
    iadb_metrics,
    lapply(iadb_graph, function(branch) {
      lapply(branch, getMetrics) %>% combineMetrics()
    }) %>%
      {do.call(rbind, .)}
  ),

  # Compute the descriptive statistical summary of the daily records
  tar_target(
    iadb_stats, lapply(tbl_iadb_split_atc, fieldSummary) %>% combineMetrics()
  ),

  # Merge graph metrics and descriptive statistics as a time-series data
  tar_target(vizDotParams, data.frame(
    "metrics" = c("n_claim", "n_patient", "claim2patient", "eigen", "pagerank"),
    "scales"  = c("free_y", "free_y", "fixed", "fixed", "fixed")
  )),

  tar_map(
    unlist = FALSE,
    values = data.frame("type" = c("day", "week", "month", "quarter")),
    tar_target(ts, mergeTS(iadb_metrics, iadb_stats, type = type)),
    tar_target(
      plt_dot,
      vizDot(ts, y = vizDotParams$metrics, scales = vizDotParams$scales, nrow = 4),
      pattern = map(vizDotParams),
      iteration = "list"
    ),
    tar_target(
      plt_acf,
      vizAutocor(ts, y = vizDotParams$metrics, type = "ACF", lag_max = 12),
      pattern = map(vizDotParams),
      iteration = "list"
    ),
    tar_target(
      plt_pacf,
      vizAutocor(ts, y = vizDotParams$metrics, type = "PACF", lag_max = 12),
      pattern = map(vizDotParams),
      iteration = "list"
    )
  ),

  ## Perform time-series decomposition per group of medications
  #tar_target(groupname, unique(ts$group) %>% as.character()),

  #tar_map(
  #  unlist = TRUE,
  #  values = tidyr::expand_grid(
  #    "period" = c(paste(1:3, "week"), paste(1:3, "month")),
  #    "method" = c("classic", "loess"),
  #    "tvar"   = c("eigen", "pagerank", "claim2patient", "n_claim")
  #  ),
  #  tar_target(
  #    iadb_decom,
  #    timeDecomp(ts, varname = tvar, group = groupname, period = period, method = method),
  #    pattern = map(groupname),
  #    iteration = "list"
  #  )
  #),

  # Generate documentation
  tar_quarto(report, "docs", profile = "report"),
  tar_quarto(readme, "README.qmd", priority = 0)

)
