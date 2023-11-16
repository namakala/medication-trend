# Functions to prepare for a graph object

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
    "Other nervous system drugs",
    "Antiparasitics",
    "Respiratory",
    "Sensory",
    "Others"
  )

  return(label)
}

pairByRow <- function(atc_tbl, ..., weight = "weight") {
  #' Make Pairwise Row Combination
  #'
  #' Create a pairwise combination for each row of the input data frame.
  #' Pairwise combination is created by indexing each row number. Indexed row
  #' entries are then paired to generate a `from` and `to` field combinations.
  #' This combination is intended for generating a graph object (see
  #' `igraphs::graph.data.frame`).
  #'
  #' @param atc_tbl A data frame containing split ATC
  #' @param weight Method to weight, either `n` or `weight`
  #' @inheritDotParams base::aggregate
  #' @return A data frame for generating graph object, containing number of
  #' edges and its weight

  # Set weight
  atc_tbl %<>% inset2("weight", value = ifelse(.$dose != 0, .$n / .$dose, .$n))

  # Get the combination index
  if (nrow(atc_tbl) > 1) {
    id   <- RcppAlgos::comboGeneral(nrow(atc_tbl), 2, nThreads = 2)
    from <- id[, 1]
    to   <- id[, 2]
  } else {
    from <- to <- 1
  }

  tbl_from <- atc_tbl[from, ] %>% set_names(paste(names(.), "from", sep = "_"))
  tbl_to   <- atc_tbl[to, ]   %>% set_names(paste(names(.), "to",   sep = "_"))

  # Combine the column based on the index
  tbl_pair <- cbind(tbl_from, tbl_to) %>%
    inset2("weight", value = {.$weight_from + .$weight_to} / 2)

  # Aggregate the metrics
  form <- sprintf("%s ~ group_from + group_to", weight) %>% as.formula()
  tbl_agg <- aggregate(form, data = tbl_pair, ...) %>%
    set_names(c("from", "to", "weight"))
  
  return(tbl_agg)
}

mkMatrix <- function(atc_tbl, ...) {
  #' Make Matrix
  #'
  #' Create an adjacency matrix from a split ATC data frame
  #'
  #' @param atc_tbl A data frame containing split ATC entries
  #' @param ... Parameter passed on to `pairByRow`
  #' @return A sparse adjacency matrix

  # Generate parameters to create an empty matrix
  label <- genLabel()
  size  <- length(label)

  # Set the group as factor
  atc_tbl %<>%
    inset2("group",  value = factor(.$group, levels = label))

  # Get a list of user IDs
  uids <- unique(atc_tbl$id) %>% set_names(., .)

  # Iterate the row entry of ATC data frame
  mtxs <- lapply(uids, function(uid) {
    sub_tbl <- atc_tbl %>% subset(.$id == uid)
    groups  <- sub_tbl$group
    agg_tbl <- pairByRow(sub_tbl, ...)

    # Generate an empty matrix as a placeholder, set locators for rows and cols
    mtx <- Matrix::Matrix(
      0, nrow = size, ncol = size,
      dimnames = label %>% list(., .),
      sparse = TRUE
    )

    loc <- with(agg_tbl, list("row" = from, "col" = to))

    # Fill in the matrix
    mtx[loc$row, loc$col] <- agg_tbl$weight

    return(mtx)
  })
   
  mtx <- Reduce(\(x, y) x + y, mtxs)

  return(mtx)
}

mkGraph <- function(atc_tbl) {
  #' Generate Graph Object
  #'
  #' Create a graph object from a pairwise combination data frame
  #'
  #' @param atc_tbl A data frame containing split ATC entries
  #' @return Medication graph from pairwises of ATC

  mtx   <- mkMatrix(atc_tbl, sum)
  graph <- igraph::graph_from_adjacency_matrix(
    mtx, weighted = TRUE, mode = "directed"
  )

  return(graph)
}

getMetrics <- function(graph) {
  #' Calculate Graph Metrics
  #'
  #' Calculate graph metrics from a given medication graphs
  #' @param graph Medication graph from pairwises of ATC
  #' @return A data frame containing node names and its metrics
  pagerank <- igraph::page_rank(graph) %>% extract2("vector")
  eigen    <- igraph::eigen_centrality(graph) %>%
    extract2("vector") %>%
    divide_by(sum(.))

  metrics <- data.frame(eigen, pagerank) %>%
    tibble::add_column("group" = rownames(.), .before = 1)

  return(metrics)
}

combineMetrics <- function(list_metrics) {
  #' Aggregate Metrics
  #'
  #' Combine a list of metrics into one data frame. This function assumes that
  #' the list is grouped by date.
  #'
  #' @param list_metrics List of graph metrics
  #' @return A combined data frame of graph metrics
  tbl <- do.call(rbind, list_metrics) %>%
    tibble::add_column(
      "date" = gsub(x = rownames(.), "\\..*", "") %>% as.Date(),
      .after = 1
    ) %>%
    tibble::tibble()

  return(tbl)
}
