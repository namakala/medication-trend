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

splitTs <- function(ts, ratio = 0.2, recent = NULL) {
  #' Split Time-Series
  #'
  #' Split the time-series into training and testing dataset based on the ratio
  #'
  #' @param ts A time series dta frame, will accept a `tsibble` object
  #' @param recent A date for specifying the split
  #' @param ratio The testing:training ratio, set to 0.2 by default
  #' @return A list containing training and testing dataset

  # Date of the most recent dataset
  if (is.null(recent)) {
    dates  <- ts$date %>% unique()
    loc    <- floor(ratio * length(dates))
    recent <- dates %>% extract2(length(.) - loc)
  }

  # Subset the dataset
  sub_ts <- list(
    "past"   = ts %>% subset(.$date <= recent),
    "recent" = ts %>% subset(.$date >  recent)
  )

  return(sub_ts)

}

genModelForm <- function(varname) {
  #' Generate Model Formulas
  #'
  #' Generate model formulas to use in `compareModel`
  #'
  #' @param varname A character vector of a variable name
  #' @return A list of formulas

  forms <- list(
    "snaive"  = "%s ~ lag(52)",
    "drift"   = "%s ~ drift()",
    "tslm"    = "%s ~ trend() + fourier(period = 'year', K = 2)",
    "ets"     = "%s ~ season(period = 24)", # Max supported period is 24
    "sarima"  = "%s ~ PDQ(period = 52)",
    "arimax"  = "%s ~ fourier(period = 'year', K = 2)",
    "prophet" = "%s ~ season(period = 'year', order = 2)"
  ) %>%
    lapply(\(form) sprintf(form, varname) %>% formula())

  return(forms)
}

compareModel <- function(ts, y, split = NULL, ...) {
  #' Compare Models
  #'
  #' Fit Multiple Models for Comparison
  #'
  #' @param ts A time series data frame, will accept a `tsibble` object
  #' @param y The variable to fit
  #' @param split A list containing parameters to pass on to `splitTs`, support
  #' either `recent` (date object) or `ratio` (0 $\leq$ ratio $\leq$ 1)
  #' @return A mable object (model table)
  require("tsibble")

  # Get variable name with englue then generate model formulas
  varname <- rlang::englue("{{ y }}")
  forms   <- genModelForm(varname)

  # Switcher to perform a rolling-window cross validation or data splitting
  if (!is.null(split)) {
    ratio   <-  split$ratio
    recent  <-  split$recent
    ts     %<>% splitTs(recent = recent, ratio = ratio) %>% extract2("past")
  }

  if (hasArg(.init) & hasArg(.step)) {
    ts %<>% tsibble::stretch_tsibble(...)
  }

  # Fit multiple models as a mable
  model <- ts %>%
    fabletools::model(
      "mean"    = fable::MEAN({{ y }}),
      "naive"   = fable::NAIVE({{ y }}),
      "snaive"  = fable::SNAIVE(forms$snaive),
      "drift"   = fable::RW(forms$drift),
      "tslm"    = fable::TSLM(forms$tslm),
      "ets"     = fable::ETS(forms$ets),
      "arima"   = fable::ARIMA({{ y }}),
      "sarima"  = fable::ARIMA(forms$sarima),
      "arimax"  = fable::ARIMA(forms$arimax),
      "prophet" = fable.prophet::prophet(forms$prophet)
    )

  return(model)
}

castModel <- function(mable, len = 52) {
  #' Forecast models
  #'
  #' Create a forecast from models in a mable
  #'
  #' @param mable A model table, usually the outoput of `compareModel`
  #' @param len The length of forecasted data points
  #' @return A forecast table

  mod_cast <- mable %>% fabletools::forecast(h = len)

  return(mod_cast)
}

evalModel <- function(mod_cast, ts) {
  #' Evaluate Comparative Models
  #'
  #' Evaluate comparative models provided by the `compareModel` function
  #'
  #' @param mod_cast A model forecast
  #' @param ts A time-series data used to evaluate the model. To calculate MASE
  #' and RMSSE, it is required to use the whole dataset (training + testing).
  #' @return A table containing model goodness of fit
  require("fabletools")

  mod_eval <- mod_cast %>%
    fabletools::accuracy(
      ts,
      list(
        "MAE"  = fabletools::MAE,
        "RMSE" = fabletools::RMSE,
        "MAPE" = fabletools::MAPE,
        "MASE" = fabletools::MASE,
        "RMSSE" = fabletools::RMSSE,
        "Winkler" = fabletools::winkler_score, 
        "QS"      = fabletools::quantile_score,
        "CRPS"    = fabletools::CRPS,
        "Skill"   = fabletools::skill_score(CRPS)
      )
    ) %>%
    dplyr::arrange(group)

  return(mod_eval)
}

