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
            plotly::plot_ly(mtcars, x = ~mpg, y = ~wt)
          )
        )
      )
    )
  )
}
