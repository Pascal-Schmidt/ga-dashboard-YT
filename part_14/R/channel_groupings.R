channel_groupings <- function(df) {
  data <- df %>%
    dplyr::group_by(channel_grouping) %>%
    dplyr::summarise(n = dplyr::n()) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(all = round(n / sum(n) * 100, 2))

  fig <- data %>%
    plot_ly(labels = ~channel_grouping, values = ~all, type = "pie")
  fig <- fig %>% layout(
    title = "",
    xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
    yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE)
  )

  return(fig)
}
