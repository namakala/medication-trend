# Functions to perform spectral analysis, especially manipulate objects from `Rssa`

reconSsa <- function(ssa, naive = TRUE, type = "cor", ...) {
  #' Reconstruct SSA Decomposition
  #'
  #' Reconstruct the SSA model to obtain its constituting functions
  #'
  #' @param ssa An SSA model, usually obtained from `fitSsa`
  #' @param naive A boolean to indicate extracting a naive reconstruction, i.e.
  #' no prior assumption on groupings
  #' @param type Type of SSA group to extract, support either `pgram`, `wcor`,
  #' or `cor`. This argument is passed on to `getSsaGroup` when `naive` is
  #' `FALSE`.
  #' @inheritDotParams Rssa::reconstruct
  require("Rssa")

  args <- list(...)

  if (naive) {
    recon  <- Rssa::reconstruct(ssa, ...)
  } else {
    groups <- getSsaGroup(ssa, type = type)
    recon  <- Rssa::reconstruct(ssa, groups = groups, ...)
  }

  ssa_attr <- base::attr(ssa, "group")

  if (!is.null(ssa_attr)) {
    base::attributes(recon)$group <- ssa_attr
  }

  return(recon)
}

getSsaGroup <- function(ssa, type = "cor", ...) {
  #' Extract SSA Groupings
  #'
  #' Extract SSA groupings automatically based on periodogram or correlation
  #' clusters
  #'
  #' @param ssa An SSA model, usually obtained from `fitSsa`
  #' @param type Type of SSA group to extract, support either `pgram`, `wcor`,
  #' or `cor`
  #' @inheritDotParams Rssa::grouping.auto
  require("Rssa")

  if (type == "cor") {

    naive  <- Rssa::reconstruct(ssa) # Avoid calling `reconSsa` to prevent cyclical call in targets
    n_col  <- length(naive)
    mtx    <- unlist(naive) %>% matrix(ncol = n_col) %>% cor(use = "complete.obs")
    groups <- apply(mtx, 1, \(x) which(abs(x) > 0.5), simplify = FALSE) %>%
      unique()

  } else if (type == "wcor") {

    groups <- Rssa::grouping.auto.wcor(ssa, ...)

  } else if (type == "pgram") {

    groups <- Rssa::grouping.auto.pgram(ssa, ...)

  } else {

    stop("Type is not supported, choose only `pgram`, `wcor`, or `cor`")

  }

  return(groups)
}

