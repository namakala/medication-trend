# Functions to visualize the data

vizDot <- function(tbl, y, ...) {
  #' Visualize the Dot Plot
  #'
  #' Visualizing the data frame content as a dot plot
  #'
  #' @param tbl Time-series data frame containing metrics and statistics of
  #' daily medication claims
  #' @param y The time-varying variable to plot
  #' @inheritDotParams ggplot2::facet_wrap
  #' @return A GGPlot object
  require("ggplot2")

  labelname <- dplyr::case_when(
    y == "n_claim" ~ "The number of medication claims",
    y == "n_patient" ~ "The number of patients prescribed for the medication",
    y == "claim2patient" ~ "Medication claim to patient ratio",
    y == "eigen" ~ "Eigenvector centrality",
    y == "pagerank" ~ "Page rank centrality"
  )

  plt <- ggplot(tbl, aes(x = date, y = get(y))) +
    geom_point(alpha = 0.4, size = 0.6) +
    facet_wrap(~group, scales = "free_y", ...) +
    labs(x = "Year", y = labelname)

  return(plt)
}
