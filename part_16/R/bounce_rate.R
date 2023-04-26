bounce_rate <- function(df) {

  df %>%
    dplyr::group_by(date) %>%
    dplyr::summarise(
      bounce_rate = mean(bounce_rate) %>% round(2)
    ) %>%
    dplyr::ungroup() -> bounce_rate

  bounce_rate %>%
    plotly::plot_ly(
      data = .,
      x = ~date,
      y = ~bounce_rate,
      type = "scatter",
      mode = "lines"
    ) -> fig

  actual_bounce <- bounce_rate %>%
    dplyr::arrange(desc(date)) %>%
    dplyr::slice(2) %>%
    .[, 2] %>%
    dplyr::pull() %>%
    round(2) %>%
    as.character()

  bounce_rate_cards <- bounce_rate %>%
    dplyr::arrange(desc(date)) %>%
    dplyr::slice(2:3) %>%
    dplyr::mutate(
      bounce_rate = ((bounce_rate[1] - bounce_rate[2])/bounce_rate[2]*100*(-1)) %>%
        round(2)
    ) %>%
    dplyr::select(-date) %>%
    .[1, ] %>%
    tidyr::pivot_longer(dplyr::everything()) %>%
    dplyr::mutate(
      icon = 'exclamation-circle',
      name = "Bounce Rate"
    ) %>%
    dplyr::mutate(
      arrow = ifelse(value < 0, "down", "up"),
      color = ifelse(value < 0, "red", "green"),
      actuals = actual_bounce
    )

  return(
    list(
      bounce_rate_fig   = fig,
      cards_bounce_rate = bounce_rate_cards
    )
  )
}
