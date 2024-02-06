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

  sub_ts <- ts %>% subset(.$group == groupname, select = y)
  mod    <- FUN(sub_ts, ...)
  
  base::attributes(mod)$group  <- groupname
  base::attributes(mod)$metric <- y

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

fitSsa <- function(ts, ...) {
  #' Fit Singular-Spectrum Model
  #'
  #' Fit a singular-spectrum analysis model using the `Rssa` package
  #'
  #' @param ts A tidy time-series data frame, should be a subset of a metric as
  #' specified by `fitModel`
  #' @inheritDotParams Rssa::ssa
  #' @return A model object
  require("Rssa")

  mod <- ts %>% extract2(1) %>% Rssa::ssa(...)

  return(mod)
}
