# Functions to visualize the data

genColor <- function() {
  #' Generate Color Palette
  #'
  #' Generate the color palette to use when plotting
  #'
  #' @return A named list of color palette
  col_palette <- list(
    "black"  = "#2E3440",
    "white"  = "#ECEFF4",
    "red"    = "#BF616A",
    "blue"   = "#5E81AC",
    "green"  = "#8FBCBB",
    "yellow" = "#EBCB8B",
    "orange" = "#D08770"
  )

  return(col_palette)
}

getLabel <- function(metric) {
  #' Get Label Name
  #'
  #' Get the label name based on the metric names
  #'
  #' @param metric A metric name from the time-series data
  #' @return A character vector signifying the label name

  labelname <- dplyr::case_when(
    metric == "n_claim" ~ "The number of medication claims",
    metric == "n_patient" ~ "The number of patients prescribed for a medication",
    metric == "claim2patient" ~ "Medication claim to patient ratio",
    metric == "eigen" ~ "Eigenvector centrality",
    metric == "pagerank" ~ "Page rank centrality",
    metric == "degree" ~ "Node degree",
    metric == "strength" ~ "Weighted node degree"
  )

  return(labelname)
}

setStripColor <- function(group) {
  #' Set Strip Color
  #'
  #' Set strip color in a faceted GGPlot2 object
  #'
  #' @param group A character vector of medication group, usually containing 25
  #' groups enlisted in the `setGroupFactor` function
  #' @return Themed strip as a `ggh4x` object
  require("ggh4x")

  colors    <- genColor()
  strip_col <- ggh4x::strip_themed(
    background_x = ggh4x::elem_list_rect(
      fill = ifelse(unique(group) %in% getNeuroMeds(), colors$green, "grey90")
    )
  )

  return(strip_col)
}

saveFig <- function(plt, path, args, ...) {
  #' Save Generated Figure
  #'
  #' Save the generated plot as a figure document written the specified path
  #'
  #' @param plt A GGPlot2 object
  #' @param path A specified path to write the figure
  #' @param args A character vector of arguments to construct the filename
  #' @inheritDotParams ggplot2::ggsave
  #' @return This function does not return anything *except* writing the figure
  #' into the specified path
  fname <- sprintf("%s.pdf", paste(args, collapse = "_"))
  fpath <- sprintf("%s/%s", path, fname)
  ggplot2::ggsave(fpath, plot = plt, device = "pdf", ...)
}

vizDot <- function(tbl, y, groupname = NULL, ...) {
  #' Visualize the Dot Plot
  #'
  #' Visualizing the data frame content as a dot plot
  #'
  #' @param tbl Time-series data frame containing metrics and statistics of
  #' daily medication claims
  #' @param y A metric name from the time-series data
  #' @param groupname A character object specifying the medication group name.
  #' If not provided (`null` by default), all groups are shown as a faceted
  #' plot.
  #' @inheritDotParams ggh4x::facet_wrap2
  #' @return A GGPlot object
  require("ggplot2")
  require("tsibble")

  colors    <- genColor()
  labelname <- getLabel(y)

  if (!is.null(groupname)) {
    tbl %<>% subset(.$group == groupname)
  }

  plt <- ggplot(tbl, aes(x = as.Date(date), y = get(y))) +
    geom_point(alpha = 0.4, size = 0.6) +
    labs(x = "Year", y = labelname) +
    ggpubr::theme_pubclean()

  if (is.null(groupname)) {
    strip_col <- setStripColor(unique(tbl$group))
    plt <- plt +
      ggh4x::facet_wrap2(~group, strip = strip_col, ...) +
      labs(
        caption = "The green label signifies medications affecting the nervous system, coded under N01-N07 in WHOCC ATC"
      ) +
      theme(
        strip.text = element_text(size = 10),
        axis.text  = element_text(size = 8)
      )
  }

  return(plt)
}

vizAutocor <- function(ts, y, type = "ACF", ...) {
  #' Visualize the Autocorrelation Plot
  #'
  #' Generate an autocorrelation plot from the output of `feasts::ACF`,
  #' `feasts::PACF`, or `feasts::CCF`
  #'
  #' @param ts A tidy time-series data frame combining graph's metrics and the
  #' field summary
  #' @param y A metric name from the time-series data
  #' @param type Type of autocorrelation, supports both `ACF` and `PACF`
  #' @inheritDotParams feasts::ACF
  #' @return A GGPlot object
  require("ggplot2")
  require("ggh4x")

  # Set plot parameters
  size      <- 0.6 # Dot size
  colors    <- genColor()
  labelname <- getLabel(y) %>% stringr::str_to_lower()
  strip_col <- setStripColor(unique(ts$group))

  # Calculate the autocorrelation
  if (type == "ACF") {
    ts_ac <- ts %>% feasts::ACF(y = get(y), ...)
  } else if (type == "PACF") {
    ts_ac <- ts %>% feasts::PACF(y = get(y), ...)
  }

  # Get the confidence interval, see `feasts:::autoplot.tbl_cf`
  conf_int <- attr(ts_ac, "num_obs") %>%
    dplyr::mutate(
      "upper" = qnorm(1.95 / 2) / sqrt(.len),
      "lower" = -upper
    ) %>%
    tidyr::pivot_longer(c(upper, lower), names_to = "type", values_to = "ci")

  # Prepare the data frame for plotting
  ts_ac %<>%
    set_names(c("group", "lag", "ac")) %>%
    dplyr::group_by(group) %>%
    dplyr::mutate(
      "maxcor" = ac == max(ac),
      "color"  = ifelse(maxcor, colors$red, colors$black),
      "size"   = ifelse(maxcor, size * 2, size)
    )

  # Generate the plot
  plt <- ggplot(ts_ac, aes(x = lag, y = ac)) +
    ylim(c(-1, 1)) +
    geom_hline(aes(yintercept = ci, group = type), data = conf_int, color = colors$black, linetype = "dashed", alpha = 0.4) +
    geom_hline(yintercept = 0, alpha = 0.8) +
    geom_segment(aes(x = lag, xend = lag, y = 0, yend = ac), alpha = 0.6, lwd = ts_ac$size, color = ts_ac$color) +
    geom_point(alpha = 0.6, size = ts_ac$size, color = ts_ac$color) +
    ggh4x::facet_wrap2(~group, nrow = 4, strip = strip_col) +
    scale_x_continuous(n.breaks = max(ts_ac$lag) %>% as.numeric() %>% divide_by(2) %>% round()) +
    labs(
      x = sprintf("Lag (%s)", tsibble:::format.interval(feasts:::interval_pull.cf_lag(ts_ac))),
      y = sprintf("%s of %s", type, labelname),
      caption = "The green label signifies medications affecting the nervous system, coded under N01-N07 in WHOCC ATC"
    ) +
    ggpubr::theme_pubclean() +
    theme(
      strip.text = element_text(size = 10),
      axis.text  = element_text(size = 8)
    )

  return(plt)
}

vizPair <- function(ts, groupname) {
  #' Generate a Pair Plot
  #'
  #' Generate a pair plot to describe the time series
  #'
  #' @param ts A tidy time-series data frame, usually the output of `mergeTS`
  #' function
  #' @param groupname A group of medication to subset the data frame
  #' @return A GGPlot2 object
  require("ggplot2")

  sub_ts <- ts %>%
    subset(.$group == groupname, select = c(eigen, strength:claim2patient, event))

  plt <- GGally::ggpairs(sub_ts, aes(color = event, alpha = 0.6)) +
    labs(title = groupname)

  return(plt)
}

vizArima <- function(mod, y, groupname, ...) {
  #' Visualize ARIMA forecast
  #'
  #' Visualize ARIMA forecast from the `forecast` package using its autoplot
  #' function
  #'
  #' @param mod An ARIMA model, usually the output of `forecast::auto.arima`
  #' @param y Metric names to set the y label
  #' @param groupname Medication group name, set as the subtitle
  #' @return A GGPlot2 object
  require("ggplot2")

  plt <- forecast::autoplot(mod) +
    labs(y = getLabel(y), subtitle = groupname) +
    ggpubr::theme_pubclean()

  return(plt)
}

vizPeriod <- function(ts, y, period = "month", groupname = NULL, ...) {
  #' Visualize Periodic Patterns
  #'
  #' Visualize patterns of a time-series data using the period as the x axis
  #'
  #' @param ts A time-series data frame, usually `ts_month` or its derivatives
  #' @param y A metric names of the time-series data
  #' @param period A period of time to observe the periodicity, currently
  #' supporting `day`, `week`, and `month`
  #' @param groupname A character object specifying the medication group name.
  #' If not provided (`null` by default), all groups are shown as a faceted
  #' plot.
  #' @inheritDotParams ggh4x::facet_wrap2
  #' @return A GGplot2 object
  require("ggplot2")
  require("tsibble")

  # Create labels for the plot
  if (!is.null(groupname)) {
    ts      %<>% subset(.$group == groupname)
    plt_lab  <-  labs(title = groupname, x = "", y = getLabel(y))
  } else {
    plt_lab  <- labs(x = "", y = getLabel(y))
  }

  # Prepare the table for plotting
  ts %<>%
    dplyr::mutate(
      "year"  = lubridate::year(date) %>% ordered(),
      "xtick" = switch(
        period,
        "day"   = lubridate::wday(date, label = TRUE),
        "week"  = lubridate::week(date) %>% as.ordered(),
        "month" = lubridate::month(date, label = TRUE)
      ),
      "color" = switch(
        period,
        "day"   = tsibble::yearweek(date) %>% as.ordered(),
        "week"  = lubridate::year(date),
        "month" = lubridate::year(date)
      ) %>% as.numeric()
    )

  # Generate plot to evaluate periodic pattern
  plt <- ggplot(ts, aes(x = xtick, y = get(y), group = color, color = color)) +
    geom_line(alpha = 0.4, linewidth = 1.5) +
    plt_lab +
    scale_color_gradient(guide = "none") +
    ggpubr::theme_pubclean()

  # Create a faceted plot when groupname is NULL
  if (is.null(groupname)) {
    strip_col <- setStripColor(unique(ts$group))
    plt <- plt +
      ggh4x::facet_wrap2(~group, strip = strip_col, ...) +
      labs(
        caption = "The green label signifies medications affecting the nervous system, coded under N01-N07 in WHOCC ATC"
      ) +
      theme(
        strip.text = element_text(size = 10),
        axis.text  = element_text(size = 8)
      )
  }

  return(plt)
}

vizMonth <- function(ts, y, groupname = NULL) {
  #' Visualize Monthly Trend
  #'
  #' Visualize trend of a monthly data using month name as the x axis
  #'
  #' @param ts A time-series data frame, usually `ts_month` or its derivatives
  #' @param y A metric names of the time-series data
  #' @param groupname A group of medication to subset the data frame
  #' @return A GGplot2 object
  require("ggplot2")
  require("tsibble")

  if (!is.null(groupname)) {
    ts      %<>% subset(.$group == groupname)
    plt_lab  <-  labs(title = groupname, x = "", y = getLabel(y))
  } else {
    plt_lab  <- labs(x = "", y = getLabel(y))
  }

  ts %<>%
    dplyr::mutate(
      "month" = lubridate::month(date, label = TRUE, abbr = FALSE),
      "year"  = lubridate::year(date) %>% ordered()
    )

  plt <- ggplot(ts, aes(x = month, y = get(y), fill = year)) +
    geom_histogram(stat = "identity", position = "dodge", alpha = 0.6) +
    plt_lab +
    ggpubr::theme_pubclean()

  return(plt)
}

vizPolar <- function(...) {
  #' Visualize a Polar Plot
  #'
  #' Visualize monthly trend with a faceted polar plot
  #'
  #' @param ... Parameters to pass on to `vizMonth`
  #' @return A GGplot2 object
  require("ggplot2")

  plt_month <- vizMonth(...)
  plt_polar <- plt_month +
    coord_polar() +
    theme(legend.position = "bottom", legend.title = element_blank())

  if (!hasArg(groupname)) {
    plt_polar <- plt_polar +
      facet_wrap(~group, nrow = 4) +
      theme(legend.position = "right", legend.title = element_blank())
  }

  return(plt_polar)
}

vizReconSsa <- function(tidy_recon, ...) {
  #' Visualize Reconstructed Time-Series
  #'
  #' Visualize the reconstructed series obtained from SSA model
  #'
  #' @param tidy_recon A tidy data frame obtained from `tidyReconSsa`
  #' @return A GGPlot2 object
  require("ggplot2")
  
  med <- unique(tidy_recon$group)
  lab <- unique(tidy_recon$metric) %>% getLabel()
  
  plt <- ggplot(tidy_recon, aes(x = date, y = value)) +
    geom_line(alpha = 0.8) +
    facet_wrap(~ component, scales = "free", ...) +
    labs(title = med, y = lab, x = "") +
    ggpubr::theme_pubclean()

  return(plt)
}
