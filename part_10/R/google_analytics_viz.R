switch_fn <- function(viz, df) {
  switch (
    viz,
    `Page Views`      = time_series_pageviews(df)$plot_pageviews,
    `Device Category` = device_category(df),
    `Day of Week`     = day_of_week(df),
    `Channels`        = channel_groupings(df),
    `Bounce Rate`     = bounce_rate(df)$bounce_rate_fig
  )
}

google_analytics_viz <- function(title = NULL, viz = NULL, btn_id, df = NULL,
                                 class_all, class_specific, color) {
  shiny::tagList(
    div(
      class = class_specific,
      div(
        class = "col-md-6",
        div(
          class = "panel panel-default",
          div(
            class = "panel-heading clearfix",
            tags$h2(title, class = "panel-title pull-left"),
            div(
              class = "pull-right",
              shiny::actionButton(
                inputId = btn_id,
                label = "",
                class = stringr::str_glue("btn-{color} {class_all}"),
                icon = shiny::icon("minus")
              )
            )
          ),
          div(
            class = "panel-body",
            switch_fn(viz, df)
            # plotly::plot_ly(mtcars, x = ~mpg, y = ~wt)
          )
        )
      )
    )
  )
}
