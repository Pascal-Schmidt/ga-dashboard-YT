device_category <- function(df) {
  data <- df %>%
    dplyr::group_by(device_category) %>%
    dplyr::summarise(n = dplyr::n()) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(all = round(n / sum(n) * 100, 2))

  fig <- plot_ly(data, labels = ~device_category, values = ~all, type = "pie")
  fig <- fig %>% layout(
    title = "",
    xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
    yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE)
  )
  return(fig)
}
