switch_fn <- function(viz, df) {
  switch (viz,
    `Page Views` = views_sessions(df)[["views_sessions_fig"]],
    `Device Category` = device_category(df),
    `Channel Groupings` = channel_groupings(df),
    `Bounce Rate` = bounce_rate(df)[["bounce_rate_plot"]],
    `Session Duration` = session_duration(df)[["session_duration_plot"]],
    `Visitor Map` = visitor_map(df),
    `Most Popular Posts` = table(df),
    `Time Series` = modeltime::plot_modeltime_forecast(df)
  )
}

google_analytics_viz <- function(class_specific, header, unique_id, viz, df) {

  div(
    class = class_specific,
    div(
      class = "col-lg-6 col-md-6 col-sm-12",
      div(
        class = "panel panel-default",
        div(
          class = 'panel-heading clearfix',
          tags$h2(header, class = "panel-title pull-left"),
          div(
            class = "pull-right",
            shiny::actionButton(
              inputId = unique_id,
              label = "",
              class = "btn-danger delete",
              icon = shiny::icon("trash")
            )
          )
        ),
        div(
          class = "panel-body",
          div(
            class = header,
            style = if(header == "Most Popular Posts") {
              "overflow-y: scroll; height: 430px;"
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
