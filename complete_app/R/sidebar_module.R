sidebar_ui <- function(id) {

  ns <- shiny::NS(id)

  shiny::tagList(
    div(
      id = "entire-sidebar",
      div(
        class = "nav",
        id    = "menu",
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

}

sidebar_server <- function(id, user, viz) {

  shiny::moduleServer(
    id,

    function(input, output, session) {

      output$sidebar_viz <- shiny::renderUI({

        header_db <- viz[viz$user == user(), ][["sidebar"]][[1]][["viz"]][[1]]
        ids_db <- viz[viz$user == user(), ][["sidebar"]][[1]][["ids"]][[1]]

        purrr::map2(
          .x = ids_db, .y = header_db,
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
