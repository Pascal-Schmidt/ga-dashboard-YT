sidebar_ui <- function(id) {
  ns <- shiny::NS(id)

  shiny::tagList(
    div(
      div(
        id = "entire-sidebar",
        span(
          id = "menu",
          class = "nav",
          div(
            id = ns("header-sidebar"),
            style = "color: white;",
            h1("Charts")
          ),
          shiny::actionLink(
            inputId = "close",
            label = "",
            icon = shiny::icon("times"),
            onclick = "close_sidebar()"
          ),
          shiny::uiOutput(outputId = ns("sidebar_viz"))
        )
      )
    )
  )
}

sidebar_server <- function(id) {
  shiny::moduleServer(
    id,

    function(input, output, session) {

      output$sidebar_viz <- shiny::renderUI({
        purrr::map2(
          .x = "d", .y = "Channels",
          ~ div(
            class = paste0("added_", .x),
            shiny::actionLink(
              inputId = .x,
              label = .y,
              class = "added_btn"
            )
          )
        )
      })
    }
  )
}
