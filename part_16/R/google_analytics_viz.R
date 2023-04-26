switch_fn <- function(viz, df) {
  switch (
    viz,
    `Page Views`      = time_series_pageviews(df)$plot_pageviews,
    `Device Category` = device_category(df),
    `Day of Week`     = day_of_week(df),
    `Channels`        = channel_groupings(df),
    `Bounce Rate`     = bounce_rate(df)$bounce_rate_fig,
    `Visitor Map`     = map(df, geo = geo),
    `Popular Posts`   = popular_posts_table(df)
  )
}

google_analytics_viz <- function(title = NULL, viz = NULL, btn_id, df,
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
            class = paste("panel-body", title),
            style = if(title == "Popular Posts") {
              style = "overflow-y: scroll; overflow-x: scroll; height: 430px;"
            } else {
              "height: 430px;"
            },
            switch_fn(viz, df)
          )
        )
      )
    )
  )
}
