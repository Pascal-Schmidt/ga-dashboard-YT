views_sessions <- function(df) {

  temp <- df %>%
    dplyr::group_by(date) %>%
    dplyr::summarise(
      page_views = sum(pageviews),
      sessions   = sum(sessions)
    ) %>%
    dplyr::ungroup()

  actuals <- temp %>%
    dplyr::arrange(desc(date)) %>%
    dplyr::slice(2) %>%
    .[, 2:3] %>%
    unlist()

  value_cards_df <- temp %>%
    dplyr::arrange(desc(date)) %>%
    dplyr::slice(2:3) %>%
    dplyr::mutate_at(vars(page_views, sessions), ~ round((.[1]-.[2])/.[2]*100, 2)) %>%
    .[1, 2:3] %>%
    tidyr::pivot_longer(dplyr::everything()) %>%
    dplyr::mutate(
      actuals = actuals,
      icon    = c("user", "eye"),
      arrow   = ifelse(value < 0, "down", "up"),
      color   = ifelse(value < 0, "red", "green"),
      value   = paste0(value, "%"),
      name    = c("Page Views", "Sessions")
    )

  fig <- plotly::plot_ly(temp, x = ~date)
  fig <- fig %>% add_lines(y = ~page_views)
  fig <- fig %>% add_lines(y = ~ sessions, visible = FALSE)

  fig <- fig %>%
    layout(
      showlegend = FALSE,
      xaxis = list(domain = range(temp$date), title = ""),
      yaxis = list(title = ""),
      updatemenus = list(
        list(
          x = 0.1,
          y = 1.25,
          buttons = list(
            list(
              method = "restyle",
              args   = list("visible", list(TRUE, FALSE)),
              label  = "Page Views"
            ),
            list(
              method = "restyle",
              args   = list("visible", list(FALSE, TRUE)),
              label  = "Sessions"
            )
          )
        )
      )
    )

  return(
    list(
      views_sessions_fig   = fig,
      views_sessions_cards = value_cards_df
    )
  )

}
