page_views <- function(df) {

  df <- df %>%
    dplyr::group_by(date) %>%
    dplyr::summarise(pageviews = sum(pageviews)) %>%
    dplyr::ungroup()

  plot <- plotly::plot_ly(
    df,
    x = ~date
  ) %>%
    plotly::add_lines(
      y = ~pageviews
    )
  return(plot)
}
