# Functions to perform clustering

fitCluster <- function(arr, ...) {
  #' Fit Clustering Model
  #'
  #' Find K-Medoid clusters from a given array using partitioning around the
  #' medoids (PAM) algorithm
  #'
  #' @param arr An array of number, could be a vector or matrix
  #' @return A cluster object

  clust <- cluster::pam(arr, pamonce = 6, ...)

  return(clust)
}

evalCluster <- function(clust, ...) {
  #' Evaluate Cluster Assignment
  #'
  #' Evaluate a cluster object
  #'
  #' @param clust A cluster object
  #' @return A tidy data frame containing evaluation metrics

  res <- cluster::silhouette(clust, ...) %>%
    data.frame() %>%
    extract2(3) %>%
    mean()

  return(res)
}

findCluster <- function(arr, nclusts = 2:10, ...) {
  #' Find Clusters
  #'
  #' Find the optimal clustering model based on the evaluation metrics
  #'
  #' @param arr An array of number, could be a vector or matrix
  #' @param nclusts An array of cluster parameter to fit
  #' @return An array of clusters with optimum clustering

  # Create a list of cluster objects
  clusts <- lapply(nclusts, function(nclust) {
    fitCluster(arr, k = nclust)
  })

  # Calculate silhouette scores and return the best-fitting clusters
  metrics <- sapply(clusts, evalCluster, ...)
  id      <- metrics %>% {which(. == max(.))}
  mod     <- clusts[[id]]

  # Ascendingly order the cluster based on its medoids rank
  lvl <- mod$medoids %>%
    data.frame() %>%
    lapply(rank, ties.method = "average") %>%
    data.frame() %>%
    rowSums() %>%
    order(decreasing = TRUE)

  # Return cluster as an ordered array
  clust <- mod$clustering %>% ordered(levels = lvl) %>% as.numeric()

  return(clust)
}

setCluster <- function(ts, nclusts = 2:10, ...) {
  #' Set Cluster
  #'
  #' Assign cluster to a data frame
  #'
  #' @param ts A tidy time series, usually the output of `genReconTs`
  #' @param nclusts An array of cluster parameter to fit
  #' @return A tidy time seires with a clustering variable
  require("tsibble")

  tbl <- tibble::as_tibble(ts)
  tbl_clust <- tbl %>%
    dplyr::mutate("cluster" = findCluster(eigen, nclusts = nclusts, ...))

  aug_tbl <- tbl_clust %>%
    tidyr::nest(.by = group) %>%
    dplyr::mutate(
      "meandiff" = purrr::map(data, ~ t.test(.x$eigen, mu = 1/24) %>% broom::tidy())
    ) %>%
    tidyr::unnest(c(data, meandiff)) %>%
    dplyr::mutate("hi_eigen" = statistic > 0)

  aug_ts <- aug_tbl %>% tsibble::as_tsibble(key = group, index = date)

  return(aug_ts)
}

