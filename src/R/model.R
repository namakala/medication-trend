# Functions to perform modelling

fitModel <- function(ts, groupname, y, FUN, ...) {
  #' Fit Time-Series Model
  #'
  #' Fit a model to explain or forecast time-series data frame
  #'
  #' @param ts A tidy time-series data frame
  #' @param groupname The name of medication group to subset the data
  #' @param y Metrics to evaluate
  #' @param FUN The function to fit in a model
  #' @param ... Parameters to specify the model
  #' @return A model object

  sub_ts <- ts %>% subset(.$group == groupname, select = c(y, "date"))
  mod    <- FUN(sub_ts[y], ...)
  
  base::attributes(mod)$group  <- groupname
  base::attributes(mod)$metric <- y
  base::attributes(mod)$date   <- sub_ts$date

  return(mod)
}

fitArima <- function(ts, ...) {
  #' Fit Auto-ARIMA Model
  #'
  #' Fit an auto-ARIMA model following Hyndman-Khandakar algorithm
  #'
  #' @param ts A tidy time-series data frame, should be a subset of a metric as
  #' specified by `fitModel`
  #' @inheritDotParams forecast::auto.arima
  #' @return A model object
  require("forecast")

  mod <- ts %>% forecast::auto.arima(...)

  return(mod)
}

fitSsa <- function(ts, method = NULL, ...) {
  #' Fit Singular-Spectrum Model
  #'
  #' Fit a singular-spectrum analysis model using the `Rssa` package
  #'
  #' @param ts A tidy time-series data frame, should be a subset of a metric as
  #' specified by `fitModel`
  #' @param method Further method for fitting the model, currently supporting
  #' sequential SSA modelling
  #' @inheritDotParams Rssa::ssa
  #' @return A model object
  require("Rssa")

  mod <- ts %>% extract2(1) %>% Rssa::ssa(...)

  if (is.null(method)) { # Quick termination when method is NULL
    return(mod)
  }

  # Continue model fitting based on the chosen method
  if (method == "sequential") {

    # Extract the reconstructed trend and residuals
    recon <- reconSsa(mod, naive = TRUE, as_tibble = FALSE, groups = 1)
    trend <- recon[[1]]
    resid <- residuals(recon)

    # Reconstruct other series from the residuals
    mod_orig <- mod
    mod      <- Rssa::ssa(resid)

    # Insert attributes to the new model
    attributes(mod)$trend  <- trend
    attributes(mod)$series <- attr(recon, "series")

  } else {

    message("Method is not supported, returning the model")
    return(mod)

  }

  return(mod)

}
