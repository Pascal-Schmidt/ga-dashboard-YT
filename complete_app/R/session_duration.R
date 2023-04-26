session_duration <- function(df) {

  temp <- df %>%
    dplyr::group_by(date) %>%
    dplyr::summarise(
      session_duration = mean(session_duration)
    ) %>%
    dplyr::ungroup()

  actuals <- temp %>%
    dplyr::arrange(desc(date)) %>%
    dplyr::slice(2) %>%
    .[, 2] %>%
    unlist() %>%
    round()

  value_cards_df <- temp %>%
    dplyr::arrange(desc(date)) %>%
    dplyr::slice(2:3) %>%
    dplyr::mutate(session_duration = round((session_duration[1]-session_duration[2])/session_duration[2]*100, 2)) %>%
    .[1, 2] %>%
    tidyr::pivot_longer(dplyr::everything()) %>%
    dplyr::mutate(
      actuals = paste(actuals, "Secs"),
      icon    = c("clock"),
      arrow   = ifelse(value < 0, "down", "up"),
      color   = ifelse(value < 0, "red", "green"),
      value   = paste0(value, "%"),
      name    = c("Session Duration")
    )

  plot <- temp %>%
    plotly::plot_ly(x = ~date, y = ~session_duration) %>%
    plotly::add_lines() %>%
    plotly::layout(
      xaxis = list(title = ""),
      yaxis = list(title = "")
    )

  return(
    list(
      session_duration_plot = plot,
      session_duration_cards = value_cards_df
    )
  )

}
