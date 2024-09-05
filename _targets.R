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
iadb    <- ifelse(is_test, iadb_raw[["sub"]], iadb_raw[["data/raw/iadb"]])

# Set the analysis pipeline
list(

  # Read the dataset then group by date
  tar_target(tbl_iadb, readIADB(iadb), format = "fst_tbl"),
  tar_group_select(tbl_iadb_by_date, tbl_iadb, by = c("month", "year")),

  # Split ATC in each grouped data frame
  tar_target(
    tbl_iadb_split_date,
    iterby(tbl_iadb_by_date, "startdat", splitAtc, "atcs"),
    pattern   = map(tbl_iadb_by_date),
    iteration = "vector"
  ),

  # Write daily entries as separate files
  tar_target(dat_iadb_split_date, writeFiles(tbl_iadb_split_date, "by-month-year")),

  # Concatenate all split ATC data frame
  tar_target(tbl_concat, catIADB("data/processed/by-month-year"), format = "parquet"),

  # Subset the dataset to return only antidepressants and anxiolytics
  tar_target(sub_tbl_iadb, subsetIADB(tbl_iadb)),
  tar_group_select(sub_tbl_iadb_by_date, sub_tbl_iadb, by = c("year")),

  # Generate summary statistics for polypharmacy
  tar_map(
    unlist = FALSE,
    values = data.frame("medication" = c("Anxiolytics", "Antidepressants")),
    tar_target(
      res_tbl_poly,
      summarizePolypharmacy(sub_tbl_iadb_by_date, medication = medication),
      pattern = map(sub_tbl_iadb_by_date),
      iteration = "vector"
    )
  ),

  tar_target(res_tbl_poly, catResPoly(res_tbl_poly_Antidepressants, res_tbl_poly_Anxiolytics, start_year = 2018)),

  # Describe the summary statistics
  tar_target(res_tbl_overview, overviewData(tbl_concat)),
  tar_target(res_tbl_stat, summarizeStat(tbl_concat)),
  tar_target(res_tbl_patient, readr::read_csv("data/processed/iadb-desc/patient.csv")),

  # Generate graph objects from the split ATC data frame
  tar_target(
    iadb_graph,
    lapply(tbl_iadb_split_date, mkGraph),
    pattern   = map(tbl_iadb_split_date),
    iteration = "list",
    priority  = 0
  ),

  # Concatenate graph objects between 2018-01-01 and 2022-12-31
  tar_target(graph_concat, catGraph(iadb_graph)),

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
    iadb_stats, lapply(tbl_iadb_split_date, fieldSummary) %>% combineMetrics()
  ),

  # Set iteration parameters of metrics and scales for visualization
  tar_target(vizdot_params, data.frame(
    "metrics" = c("n_claim", "n_patient", "claim2patient", "eigen", "strength"),
    "scales"  = c("free_y", "free_y", "fixed", "fixed", "fixed")
  )),

  # Set the date for COVID-19 pandemic
  tar_target(covid_date, as.Date("2020-03-11")),

  # Merge graph metrics and descriptive statistics as a time-series data
  tar_map(
    unlist = FALSE,
    values = data.frame("type" = c("day", "week", "month")),

    # Merge time-series and calculate the first-degree diff
    tar_target(ts, mergeTS(iadb_metrics, iadb_stats, covid_date = covid_date, type = type)),
    tar_target(ts_diff, timeDiff(ts)),
    tar_target(ts_diff2, timeDiff(ts, n = 2)),

    # Assess stationarity using the Augmented Dickey-Fuller test
    tar_target(ts_uroot, evalUnitRoot(ts, y = vizdot_params$metrics), pattern = map(vizdot_params)),
    tar_target(ts_diff_uroot, evalUnitRoot(ts_diff, y = vizdot_params$metrics), pattern = map(vizdot_params)),
    tar_target(ts_diff2_uroot, evalUnitRoot(ts_diff2, y = vizdot_params$metrics), pattern = map(vizdot_params)),

    # Visualize the dot plot
    tar_target(
      plt_dot,
      vizDot(ts, y = vizdot_params$metrics, scales = vizdot_params$scales, nrow = 4),
      pattern = map(vizdot_params),
      iteration = "list"
    ),

    tar_target(
      plt_dot_diff,
      vizDot(ts_diff, y = vizdot_params$metrics, scales = vizdot_params$scales, nrow = 4),
      pattern = map(vizdot_params),
      iteration = "list"
    ),

    # Visualize the pair plot, ACF, and PACF
    tar_target(
      plt_acf,
      vizAutocor(ts, y = vizdot_params$metrics, type = "ACF", lag_max = 52),
      pattern = map(vizdot_params),
      iteration = "list"
    ),

    tar_target(
      plt_acf_diff,
      vizAutocor(ts_diff, y = vizdot_params$metrics, type = "ACF", lag_max = 52),
      pattern = map(vizdot_params),
      iteration = "list"
    ),

    tar_target(
      plt_pacf,
      vizAutocor(ts, y = vizdot_params$metrics, type = "PACF", lag_max = 52),
      pattern = map(vizdot_params),
      iteration = "list"
    ),

    tar_target(
      plt_pacf_diff,
      vizAutocor(ts_diff, y = vizdot_params$metrics, type = "PACF", lag_max = 52),
      pattern = map(vizdot_params),
      iteration = "list"
    ),

    # Visualize the periodic patterns
    tar_target(
      plt_period,
      vizPeriod(ts_diff, y = vizdot_params$metrics, period = type, nrow = 4, scales = "free"),
      pattern = map(vizdot_params),
      iteration = "list"
    ),

    # Write generated plots into the specified dir
    tar_target(
      fig_dot,
      saveFig(
        plt_dot,
        path   = "docs/_fig",
        args   = c("plt_dot", type, vizdot_params$metrics),
        width  = 14,
        height = 8
      ),
      pattern = map(plt_dot, vizdot_params),
      format = "file"
    ),

    tar_target(
      fig_acf,
      saveFig(
        plt_acf,
        path   = "docs/_fig",
        args   = c("plt_acf", type, vizdot_params$metrics),
        width  = 12,
        height = 8
      ),
      pattern = map(plt_acf, vizdot_params),
      format = "file"
    ),

    tar_target(
      fig_pacf,
      saveFig(
        plt_pacf,
        path   = "docs/_fig",
        args   = c("plt_pacf", type, vizdot_params$metrics),
        width  = 12,
        height = 8
      ),
      pattern = map(plt_pacf, vizdot_params),
      format = "file"
    )
  ),

  # Set medication groups for iteration
  tar_target(med_groups, unique(ts_month$group)),

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
      "tvar"   = c("eigen", "strength", "claim2patient", "n_claim")
    ),
    tar_map(
      unlist = TRUE,
      values = list(
        "ts_dat" = rlang::syms(paste("ts", c("day", "week", "month"), sep = "_")),
        "period" = paste(1, c("week", "month", "year"))
      ),
      tar_target(decom, timeDecom(ts_dat, varname = tvar, period = period, method = method)),
      tar_target(
        plt_dot_decom,
        vizDot(decom, y = "season_adjust", nrow = 4) + labs(y = getLabel(tvar))
      )
    )
  ),

  # Set variables to iterate
  tar_map(
    unlist = FALSE,
    values = list("y" = c("n_claim", "claim2patient", "eigen")),

    # Generate polar plots on monthly basis
    tar_target(
      plt_polar,
      vizPolar(ts = ts_diff_month, y = y, groupname = med_groups),
      pattern = map(med_groups),
      iteration = "list"
    ),

    # Fit ARIMA models
    tar_target(
      mod_arima,
      fitModel(ts_week, groupname = med_groups, y = y, FUN = fitArima, test = "pp"),
      pattern = map(med_groups),
      iteration = "list"
    ),

    # Evaluate ARIMA models
    tar_target(
      mod_arima_eval,
      feasts::ljung_box(mod_arima %>% extract2("residuals")),
      pattern = map(mod_arima),
      iteration = "list"
    ),

    # Forecast ARIMA models
    tar_target(
      mod_arima_forecast,
      forecast::forecast(mod_arima),
      pattern = map(mod_arima),
      iteration = "list"
    ),

    tar_target(
      plt_arima_forecast,
      vizArima(mod_arima_forecast, y = y, groupname = med_groups),
      pattern = map(mod_arima_forecast, med_groups),
      iteration = "list"
    ),

    # Fit SSA models to decompose the time series based on singular spectrum analysis
    tar_target(
      mod_ssa,
      fitModel(ts_week, groupname = med_groups, y = y, FUN = fitSsa, method = "sequential", kind = "1d-ssa", L = 52),
      pattern = map(med_groups),
      iteration = "list"
    ),

    # Reconstruct decomposed time-series obtained from the SSA models
    tar_target(
      mod_ssa_recon,
      reconSsa(mod_ssa, naive = FALSE, type = "wcor"),
      pattern = map(mod_ssa),
      iteration = "list"
    ),

    tar_target(plt_ssa_recon, vizReconSsa(mod_ssa_recon), pattern = map(mod_ssa_recon), iteration = "list")

  ),

  # Combine SSA-based decomposition
  tar_target(
    decom_ssa,
    bindReconSsa(
      list(
        mod_ssa_recon_n_claim,
        mod_ssa_recon_claim2patient,
        mod_ssa_recon_eigen
      )
    )
  ),

  # Generate reconstructed time series based on trend + 2 oscillating functions
  tar_target(ts_recon, genReconTs(decom_ssa, n = 2)),
  tar_target(res_recon_stat, mergeReconSummary(ts_recon, res_tbl_stat)),

  # Plot the reconstructed time-series
  tar_map(
    unlist = TRUE,
    values = tibble::tibble(
      "varname" = c("n_claim", "eigen"), "scales" = c("free_y", "fixed")
    ),
    tar_target(plt_dot_recon, vizDot(ts_recon, y = varname, scales = scales, nrow = 4))
  ),

  # Compare time-series models and produce a model evaluation table
  tar_map(
    unlist = FALSE,
    values = tibble::tibble("y" = rlang::syms(c("n_claim", "eigen"))),

    # Rolling-window cross validation and model evaluation
    tar_target(mod, compareModel(ts_recon, y, split = list("ratio" = 0.2), .init = 52, .step = 13)),
    tar_target(mod_cast, castModel(mod, len = 52)),
    tar_target(mod_eval, evalModel(mod_cast, ts_recon)),

    # Fit models for an interrupted time-series analysis
    tar_target(mod_its, compareModel(ts_recon, y, split = list("recent" = covid_date))),
    tar_target(mod_cast_its, castModel(mod_its, len = 52))
  ),

  # Cluster the series based on eigenvector centrality
  tar_target(ts_clust, setCluster(ts_recon, nclusts = 2:10)),

  # Indicate medication groups with high eigenvector centrality
  tar_target(plt_hi_eigen, vizEigenCluster(ts_clust, ncol = 3, scales = "free_y")),
  tar_target(plt_hi_eigen_box, vizEigenBox(ts_clust)),

  # Generate documentation
  tar_quarto(abstract, "docs/abstract/abstract.qmd"),
  tar_quarto(abstract_eupha, "docs/abstract/eupha.qmd"),
  tar_quarto(abstract_ispor, "docs/abstract/ispor.qmd"),
  tar_quarto(report, "docs", profile = "report", extra_files = "docs/exec-summary", priority = 0),
  tar_quarto(summary, "docs", profile = "summary", priority = 0),
  tar_quarto(report_descriptive, "docs", profile = "descriptive", priority = 0),
  tar_quarto(report_arima, "docs", profile = "arima", priority = 0),
  tar_quarto(report_seasonality, "docs", profile = "seasonality", priority = 0),
  tar_quarto(report_spectral, "docs", profile = "spectral", priority = 0),
  tar_quarto(article, "docs/article.qmd"),
  tar_quarto(readme, "README.qmd", priority = 0)

)
