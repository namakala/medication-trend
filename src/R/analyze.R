# Functions to analyze the tabular data

fieldSummary <- function(tbl) {
  #' Summary of Multiple Fields
  #'
  #' Calculate descriptive statistical summary using several fields. This
  #' function takes a split ATC data frame as its input, which is already
  #' grouped per day.
  #'
  #' @param tbl Split ATC data frame
  #' @return An aggregate data frame
  res <- tbl %>%
    dplyr::group_by(group) %>%
    dplyr::summarize(
      "n_claim"       = sum(n),
      "n_patient"     = unique(id) %>% length(),
      "claim2patient" = sum(n) / length(unique(id))
    ) %>%
    data.frame() # To preserve row number when binding the rows

  return(res)
}
