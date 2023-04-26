time_series_pageviews <- function(df) {

  page_view_df <- df %>%
    group_by(date) %>%
    dplyr::summarise(
      pageviews = sum(pageviews),
      sessions = sum(sessions)
    ) %>%
    dplyr::ungroup()

  actual_views <- page_view_df %>%
    dplyr::arrange(desc(date)) %>%
    dplyr::slice(2) %>%
    .[, 2:3] %>%
    unlist() %>%
    as.character()

  cards_page_view <- page_view_df %>%
    dplyr::arrange(desc(date)) %>%
    dplyr::slice(2:3) %>%
    dplyr::mutate_at(
      vars(pageviews, sessions),
      ~ ((.[1] - .[2])/.[2]*100) %>% round(2)
    ) %>%
    dplyr::select(-date) %>%
    .[1, ] %>%
    tidyr::pivot_longer(dplyr::everything()) %>%
    dplyr::mutate(
      icon = c("eye", 'user'),
      name = c("Page Views", "Sessions")
    ) %>%
    dplyr::mutate(
      arrow = ifelse(value < 0, "down", "up"),
      color = ifelse(value < 0, "red", "green"),
      actuals = actual_views
    )

  fig <- plot_ly(page_view_df, x = ~date)
  fig <- fig %>% add_lines(y = ~pageviews, name = "Page Views")
  fig <- fig %>% add_lines(y = ~sessions, name = "Sessions", visible = F)
  fig <- fig %>% layout(
    xaxis = list(domain = range(page_view_df$date), title = ""),
    yaxis = list(title = ""),
    updatemenus = list(
      list(
        y = 1.25,
        x = 0,
        buttons = list(
          list(
            method = "restyle",
            args = list("visible", list(TRUE, FALSE)),
            label = "Page Views"
          ),

          list(
            method = "restyle",
            args = list("visible", list(FALSE, TRUE)),
            label = "Sessions"
          )
        )
      )
    )
  )

  return(
    list(
      plot_pageviews       = fig,
      cards_views_sessions = cards_page_view
    )
  )
}
