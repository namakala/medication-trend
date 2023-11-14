# Load packages
pkgs <- c("magrittr", "targets", "tarchetypes", "crew")
pkgs_load <- sapply(pkgs, library, character.only = TRUE)

# Source user-defined functions
funs <- list.files("src/R", pattern = "*.R", full.name = TRUE) %>%
  lapply(source)

# Set options for targets
tar_option_set(
  controller = crew_controller_local(workers = 4), # Enable parallel processing
  storage    = "worker",
  retrieval  = "worker",
  memory     = "transient", # Free up superfluous data
  garbage_collection = TRUE
)

# Set paths for the raw data
iadb <- lsData(pattern = "iadb")

# Set the analysis pipeline
list(

  # Read the dataset then group by date
  tar_target(tbl_iadb, readIADB(iadb[[2]]), format = "fst_tbl"),
  tar_group_select(tbl_iadb_by_date, tbl_iadb, by = c("month", "year")),

  # Split ATC in each grouped data frame
  tar_target(
    tbl_iadb_split_atc,
    iterby(tbl_iadb_by_date, "startdat", splitAtc, "atcs"),
    pattern   = map(tbl_iadb_by_date),
    iteration = "vector"
  ),

  # Generate documentation
  tar_quarto(readme, "README.qmd", priority = 0)

)
