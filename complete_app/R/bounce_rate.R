bounce_rate <- function(df) {

  temp <- df %>%
    dplyr::group_by(date) %>%
    dplyr::summarise(
      bounce_rate = mean(bounce_rate)
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
    dplyr::mutate(bounce_rate = round((bounce_rate[1]-bounce_rate[2])/bounce_rate[2]*100, 2)) %>%
    .[1, 2] %>%
    tidyr::pivot_longer(dplyr::everything()) %>%
    dplyr::mutate(
      actuals = paste0(actuals, "%"),
      icon    = c("exclamation-circle"),
      arrow   = ifelse(value < 0, "down", "up"),
      color   = ifelse(value > 0, "red", "green"),
      value   = paste0(value, "%"),
      name    = c("Bounce Rate")
    )

  plot <- temp %>%
    plotly::plot_ly(x = ~date, y = ~bounce_rate) %>%
    plotly::add_lines() %>%
    plotly::layout(
      xaxis = list(title = ""),
      yaxis = list(title = "")
    )

  return(
    list(
      bounce_rate_plot = plot,
      bounce_rate_cards = value_cards_df
    )
  )

}

