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

  # Generate documentation
  tar_quarto(readme, "README.qmd", priority = 0)

)
