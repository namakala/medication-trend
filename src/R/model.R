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

  # Extract the reconstructed trend and residuals
  recon <- reconSsa(mod, naive = TRUE, as_tibble = FALSE, groups = 1)
  trend <- recon[[1]]
  resid <- residuals(recon)

  # Insert attributes to the new model
  attributes(mod)$trend  <- trend
  attributes(mod)$series <- attr(recon, "series")

  # Continue model fitting based on the chosen method
  if (method == "sequential") {

    # Reconstruct other series from the residuals
    mod <- Rssa::ssa(resid)

    # Insert attributes to the new model
    attributes(mod)$trend  <- trend
    attributes(mod)$series <- attr(recon, "series")

  } else {

    message("Method is not supported, returning the model")

  }

  return(mod)

}

splitTs <- function(ts, ratio = 0.2) {
  #' Split Time-Series
  #'
  #' Split the time-series into training and testing dataset based on the ratio
  #'
  #' @param ts A time series dta frame, will accept a `tsibble` object
  #' @param ratio The testing:training ratio, set to 0.2 by default
  #' @return A list containing training and testing dataset

  # Date of the most recent dataset
  dates  <- ts$date %>% unique()
  id     <- floor(ratio * length(dates))
  recent <- dates %>% extract2(length(.) - id)

  # Subset the dataset
  sub_ts <- list(
    "train" = ts %>% subset(.$date <= recent),
    "test"  = ts %>% subset(.$date >  recent)
  )

  return(sub_ts)

}

compareModel <- function(ts, y) {
  #' Compare Models
  #'
  #' Fit Multiple Models for Comparison
  #'
  #' @param ts A time series data frame, will accept a `tsibble` object
  #' @param y The variable to fit
  #' @return A mable object (model table)
  require("tsibble")

  # Get variable name with englue
  varname <- rlang::englue("{{ y }}")

  # Generate formulas for specific models
  forms <- list(
    "snaive" = "%s ~ lag(52)",
    "drift"  = "%s ~ drift()",
    "tslm"   = "%s ~ trend()",
    "ets"    = "%s ~ error('A') + trend('N') + season('N')"
  ) %>%
    lapply(\(form) sprintf(form, varname) %>% formula())

  # Fit multiple models as a mable
  model <- ts %>%
    fabletools::model(
      "mean"   = fable::MEAN({{ y }}),
      "naive"  = fable::NAIVE({{ y }}),
      "snaive" = fable::SNAIVE(forms$snaive),
      "drift"  = fable::RW(forms$drift),
      "tslm"   = fable::TSLM(forms$tslm),
      "ets"    = fable::ETS(forms$ets),
      "arima"  = fable::ARIMA({{ y }})
    )

  return(model)
}
