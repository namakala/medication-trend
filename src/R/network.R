# Functions to prepare for a graph object

pairByRow <- function(atc_tbl, all = FALSE) {
  #' Make Pairwise Row Combination
  #'
  #' Create a pairwise combination for each row of the input data frame.
  #' Pairwise combination is created by indexing each row number. Indexed row
  #' entries are then paired to generate a `from` and `to` field combinations.
  #' This combination will is useful for generating a graph object (see
  #' `igraphs::graph.data.frame`).
  #'
  #' @param atc_tbl A data frame containing split ATC
  #' @param all Boolean indicating whether to return a complete list of
  #' weight or not
  #' @return A data frame for generating graph object, containing number of
  #' edges and its weight

  # Set weight
  atc_tbl %<>% inset2("weight", value = ifelse(.$dose != 0, .$n / .$dose, .$n))

  # Get the combination index
  id   <- RcppAlgos::comboGeneral(nrow(atc_tbl), 2, nThreads = 2)
  from <- id[, 1]
  to   <- id[, 2]

  tbl_from <- atc_tbl[from, ] %>% set_names(paste(names(.), "from", sep = "_"))
  tbl_to   <- atc_tbl[to, ]   %>% set_names(paste(names(.), "to",   sep = "_"))

  # Combine the column based on the index
  tbl_pair <- cbind(tbl_from, tbl_to) %>%
    inset2("weight", value = mean(c(.$weight_from, .$weight_to)))
  return(tbl_pair)

  # Aggregate the metrics
  if (all) {

    tbl_agg <- tbl_pair %>% {
      list(
        aggregate(n_from ~ group_from + group_to, data = ., sum),
        aggregate(N_from ~ group_from + group_to, data = ., mean),
        aggregate(weight ~ group_from + group_to, data = ., sum)
      )
    } %>%
      {Reduce(\(x, y) merge(x, y), .)} %>%
      set_names(c("from", "to", "n", "N", "weight")) %>%
      inset2("reg_n", value = .$n / .$N)

  } else {

    tbl_agg <- aggregate(weight ~ group_from + group_to, data = tbl_pair, sum) %>%
      set_names(c("from", "to", "weight"))

  }

  return(tbl_agg)
}

mkGraph <- function(atc_tbl) {
  #' Generate Graph Object
  #'
  #' Create a graph object from a pairwise combination data frame
  #'
  #' @param atc_tbl A data frame containing split ATC
  #' @return Medication graph from pairwises of ATC

  tbl_agg <- pairByRow(atc_tbl)
  tbl     <- tbl_agg %>% extract(c("from", "to", "weight"))
  graph   <- igraph::graph_from_data_frame(tbl, directed = FALSE)

  return(graph)
}

getMetrics <- function(graph) {
  #' Calculate Graph Metrics
  #'
  #' Calculate graph metrics from a given medication graphs
  #' @param graph Medication graph from pairwises of ATC
  #' @return A data frame containing node names and its metrics
  pagerank <- igraph::page_rank(graph) %>% extract2("vector")
  eigen <- igraph::eigen_centrality(graph) %>%
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
