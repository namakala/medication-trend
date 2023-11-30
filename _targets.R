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

    # Merge time-series and calculate the descriptive stat
    tar_target(ts, mergeTS(iadb_metrics, iadb_stats, type = type)),

    # Visualize the dot plot
    tar_target(
      plt_dot,
      vizDot(ts, y = vizDotParams$metrics, scales = vizDotParams$scales, nrow = 4),
      pattern = map(vizDotParams),
      iteration = "list"
    ),

    # Visualize the pair plot, ACF, and PACF
    tar_target(
      plt_acf,
      vizAutocor(ts, y = vizDotParams$metrics, type = "ACF", lag_max = 24),
      pattern = map(vizDotParams),
      iteration = "list"
    ),

    tar_target(
      plt_pacf,
      vizAutocor(ts, y = vizDotParams$metrics, type = "PACF", lag_max = 24),
      pattern = map(vizDotParams),
      iteration = "list"
    ),

    # Write generated plots into the specified dir
    tar_target(
      fig_dot,
      saveFig(
        plt_dot,
        path   = "docs/_fig",
        args   = c("plt_dot", type, vizDotParams$metrics),
        width  = 14,
        height = 8
      ),
      pattern = map(plt_dot, vizDotParams),
      format = "file"
    ),

    tar_target(
      fig_acf,
      saveFig(
        plt_acf,
        path   = "docs/_fig",
        args   = c("plt_acf", type, vizDotParams$metrics),
        width  = 12,
        height = 8
      ),
      pattern = map(plt_acf, vizDotParams),
      format = "file"
    ),

    tar_target(
      fig_pacf,
      saveFig(
        plt_pacf,
        path   = "docs/_fig",
        args   = c("plt_pacf", type, vizDotParams$metrics),
        width  = 12,
        height = 8
      ),
      pattern = map(plt_pacf, vizDotParams),
      format = "file"
    )
  ),

  # Set medication groups for iteration
  tar_target(med_groups, unique(ts_quarter$group)),

  # Descriptive statistics on the time-series data
  tar_target(desc_ts, describe(ts_day, type = "mean")),
  tar_target(
    plt_pair,
    describe(ts_day, type = "pair", groupname = med_groups),
    pattern = map(med_groups),
    iteration = "list"
  ),

  # Perform time-series decomposition per metrics
  tar_map(
    unlist = TRUE,
    values = tidyr::expand_grid(
      "method" = c("classic", "loess"),
      "tvar"   = c("eigen", "pagerank", "claim2patient", "n_claim")
    ),
    tar_map(
      unlist = TRUE,
      values = list(
        "ts_dat" = rlang::syms(paste("ts", c("day", "week", "month"), sep = "_")),
        "period" = paste(1, c("week", "month", "year"))
      ),
      tar_target(decom, timeDecomp(ts_dat, varname = tvar, period = period, method = method)),
      tar_target(
        plt_decom,
        vizDot(decom, y = "season_adjust", nrow = 4) + labs(y = getLabel(tvar))
      )
    )
  ),

  # Generate documentation
  tar_quarto(report, "docs", profile = "report"),
  tar_quarto(readme, "README.qmd", priority = 0)

)
