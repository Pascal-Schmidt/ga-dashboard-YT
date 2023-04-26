channel_groupings <- function(df) {

  df_plot <- df %>%
    dplyr::group_by(channel_grouping) %>%
    dplyr::summarise(n = dplyr::n()) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(prop = round(n/sum(n)*100, 2))

  final_plot <- plotly::plot_ly(df_plot, labels = ~  channel_grouping, values = ~prop, type = "pie")
  return(final_plot)

}
