device_category <- function(df) {

  df_plot <- df %>%
    dplyr::group_by(device_category) %>%
    dplyr::summarise(n = dplyr::n()) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(prop = round(n/sum(n)*100, 2))

  final_plot <- plotly::plot_ly(df_plot, labels = ~  device_category, values = ~prop, type = "pie")
  return(final_plot)
}
