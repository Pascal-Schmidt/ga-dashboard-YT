day_of_week <- function(df) {
  df %>%
    group_by(day_of_week_name) %>%
    dplyr::summarise(Channel = dplyr::n()) %>%
    dplyr::mutate(day_of_week_name = factor(
      day_of_week_name,
      levels = c(
        "Monday", "Tuesday",
        "Wednesday", "Thursday",
        "Friday", "Saturday",
        "Sunday"
      )
    )) -> df

  plotly::plot_ly(
    data = df,
    x = ~day_of_week_name,
    y = ~Channel,
    type = "bar"
  ) -> fig

  return(fig)
}
