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
