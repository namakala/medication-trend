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
    metric == "n_claim" ~ "The number of medication dispensing",
    metric == "n_patient" ~ "The number of patients prescribed for a medication",
    metric == "claim2patient" ~ "Medication claim to patient ratio",
    metric == "eigen" ~ "Eigenvector centrality",
    metric == "pagerank" ~ "Page rank centrality",
    metric == "degree" ~ "Node degree",
    metric == "strength" ~ "Weighted node degree"
  )

  return(labelname)
}

setStripColor <- function(group, ref = NULL) {
  #' Set Strip Color
  #'
  #' Set strip color in a faceted GGPlot2 object
  #'
  #' @param group A character vector of medication group, usually containing 25
  #' groups enlisted in the `setGroupFactor` function
  #' @param ref A reference group to use a different color
  #' @return Themed strip as a `ggh4x` object
  require("ggh4x")

  if (is.null(ref)) {
    ref <- getNeuroMeds()
  }

  colors    <- genColor()
  strip_col <- ggh4x::strip_themed(
    background_x = ggh4x::elem_list_rect(
      fill = ifelse(unique(group) %in% ref, colors$green, "grey90")
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
    geom_line(alpha = 0.2, linewidth = 0.4) +
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
  
  # Separate oscillating functions + noise from the rest
  id      <- grepl(x = tidy_recon$component, "^F")
  tbl_fun <- subset(tidy_recon, id)
  resid   <- tidy_recon %>% subset(.$component == "Residuals")
  tbl     <- tidy_recon %>%
    subset(!{id | .$component == "Residuals"}) %>%
    tidyr::pivot_wider(names_from = component, values_from = value)

  # Set labels and colors
  med <- unique(tidy_recon$group)
  lab <- unique(tidy_recon$metric) %>% getLabel()
  colors <- genColor()
  plt_title <- sprintf("%s of %s", lab, stringr::str_to_lower(med))

  # Scale the date (x) axis
  scale_date <- scale_x_date(
    date_breaks = "1 month", date_labels = "%b %Y", expand = expansion(add = c(10, 30))
  )

  # Plot for original and trend
  plt1 <- ggplot(tbl, aes(x = date)) +
    geom_point(aes(y = Original), color = colors$black, alpha = 0.4, size = 2, shape = 18) +
    geom_line(aes(y = Original, color = "Data"), alpha  = 0.2, linewidth = 1.2) +
    geom_line(aes(y = Trend, color = "Reconstructed"), alpha  = 0.8, linewidth = 2) +
    labs(title = plt_title, x = "", y = "") +
    scale_date +
    scale_color_manual(
      name = "",
      values = c("Data" = colors$black, "Reconstructed" = colors$green),
      guide = guide_legend(override.aes = aes(fill = NA))
    ) +
    ggpubr::theme_pubclean() +
    theme(
      axis.ticks.y = element_blank(),
      axis.text.x = element_text(angle = 45, vjust = 0.8, hjust = 1),
      legend.position = c(0.05, 0.9)
    )

  # Plot for the residuals
  plt2 <- ggplot(resid, aes(x = date, y = value)) +
    geom_point(alpha = 0.3, size = 1.5, color = colors$black) +
    geom_line(alpha  = 0.3, size = 0.8, color = colors$black) +
    labs(subtitle = "Residuals", x = "", y = "") +
    scale_date +
    theme_minimal() +
    theme(
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      axis.text.y = element_text(size = 8),
      axis.text.x = element_blank()
    )

  # Plot for oscillating functions
  plt3 <- ggplot(tbl_fun, aes(x = date, y = value)) +
    geom_point(alpha = 0.3, color = colors$black, size = 0.8) +
    geom_line(alpha =  0.3, color = colors$black, linewidth = 0.8) +
    facet_wrap(~component, scales = "free_y", ...) +
    labs(subtitle = "Oscillating functions contributing to the periodicity", x = "", y = "") +
    scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
    theme_minimal() +
    theme(
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      axis.text.x = element_text(size = 8),
      axis.text.y = element_text(size = 6)
    )

  # Combine the plots
  plt <- ggpubr::ggarrange(plt1, plt2, plt3, ncol = 1, heights = c(5, 1, 3))

  return(plt)
}

vizForecast <- function(mod_cast, ts) {
  #' Plot Forecast Model
  #'
  #' Plot forecasted points alongside the actual data
  #'
  #' @param mod_cast The forecasted points acquired from models, currently
  #' support a `fbl_ts`
  #' @param ts A time series data frame
  #' @return A GGplot2 object
  require("ggplot2")
  require("fabletools")

  plt <- fabletools::autoplot(mod_cast, ts) +
    facet_wrap(~group, nrow = 4, scales = "free_y")

  return(plt)
}

vizEigenCluster <- function(ts_clust, ...) {
  #' Visualize Eigenvector Centrality Cluster
  #'
  #' Generate histogram + density plot of eigenvector centrality for each
  #' medication group.
  #'
  #' @param ts_clust An augmented time-series containing cluster and one-sample
  #' T-test
  #' @return A GGPlot2 object
  require("ggplot2")

  tbl       <- ts_clust
  ref       <- tbl %>% subset(.$hi_eigen) %>% extract2("group") %>% unique()
  colors    <- genColor()
  strip_col <- setStripColor(unique(tbl$group), ref = ref)

  note <- tbl %>%
    subset(select = c(group, estimate, conf.low, conf.high, hi_eigen)) %>%
    unique() %>%
    dplyr::mutate(
      "xpos" = conf.high,
      "note" = sprintf(
        "c[e] == '%.3f [%.3f - %.3f]'", estimate, conf.low, conf.high
      )
    )

  plt <- ggplot(tbl, aes(x = eigen, fill = hi_eigen, color = hi_eigen)) +
    geom_density(alpha = 0.4) +
    geom_histogram(bins = 50, aes(alpha = hi_eigen)) +
    geom_vline(xintercept = 1/24, linetype = 2, color = "grey60") +
    annotate("text", label = "Expected value", y = Inf, x = 1/24, hjust = -0.05, vjust = 1.5, color = "grey40") +
    geom_label(
      data = note,
      aes(label = note, y = -Inf, x = -Inf),
      size  = 3,
      vjust = -1,
      hjust = "inward",
      alpha = 0.4,
      parse = TRUE,
      inherit.aes = FALSE
    ) +
    ggh4x::facet_wrap2(~group, strip = strip_col, ...) +
    ggpubr::theme_pubclean() +
    scale_color_manual(values = c("grey60", colors$green)) +
    scale_fill_manual(values  = c("grey60", colors$green)) +
    scale_alpha_manual(values = c(0.4, 0.8)) +
    labs(x = "Eigenvector centrality", y = "Number of observation") +
    theme(
      legend.position = "none"
    )

  return(plt)
}

vizEigenBox <- function(ts_clust, ...) {
  #' Visualize Eigenvector Centrality Box Plot
  #'
  #' Generate box plot of eigenvector centrality for each medication group.
  #'
  #' @param ts_clust An augmented time-series containing cluster and one-sample
  #' T-test
  #' @return A GGPlot2 object
  require("ggplot2")

  colors <- genColor()

  tbl <- ts_clust |>
    dplyr::mutate("group" = reorder(group, eigen, median, na.rm = TRUE))

  plt <- ggplot(tbl, aes(x = eigen, y = group)) +
    geom_vline(xintercept = 1/24, linetype = 2, color = "grey60") +
    geom_boxplot(aes(fill = hi_eigen, color = hi_eigen, alpha = hi_eigen), show.legend = FALSE) +
    ggpubr::theme_pubclean() +
    labs(x = "", y = "") +
    scale_x_continuous(expand = c(0, 0)) +
    scale_fill_manual(values = c("grey60", colors$green)) +
    scale_color_manual(values = c("grey60", colors$green)) +
    scale_alpha_manual(values = c(0.5, 0.7)) +
    theme(axis.ticks = element_blank())

  return(plt)
}

vizConnectivity <- function(graph_concat) {
  #' Visualize DPN Connectivity
  #'
  #' Visualize the connectivity in a concatenated graph. The concatenated
  #' graph is a reduced list of daily drug prescription network, where the
  #' edges represent number of connection throughout the years.
  #'
  #' @param graph_concat A concatenated graph object, usually the output of
  #' `catGraph`
  #' @return A GGPlot2 object
  require("ggraph")

  # Prepare the table for visualization
  tbl <- graph_concat |>
    tidygraph::as_tbl_graph() |>
    tidygraph::activate(edges) |>
    dplyr::mutate(
      "width" = cut(weight, breaks = 3)
    )

  # Generate the plot
  plt <- graph_concat |>
    ggraph::ggraph() |>
    ggraph::geom_edge_fan() |>
    ggraph::geom_node_point()

  return(plt)
}

vizReconResult <- function(ts, ts_recon, ...) {
  #' Visualize the Reconstruction Results
  #'
  #' Visualize the reconstructed time-series side-by-side with the original
  #' time-series data.
  #'
  #' @param ts The original time-series data
  #' @param ts_recon The reconstructed time-series data
  #' @param ... Parameters being passed on to `vizDot`
  #' @return A GGPlot2 object
  require("ggplot2")

  plt1 <- vizDot(ts, ...)
  plt2 <- vizDot(ts_recon, ...)
  plt  <- ggpubr::ggarrange(plt1, plt2, nrow = 1, align = "v")

  return(plt)
}
