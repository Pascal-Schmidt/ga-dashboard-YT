value_cards_ui <- function(id) {

  ns <- shiny::NS(id)

  shiny::tagList(
    shiny::uiOutput(outputId = ns("value_cards"))
  )

}

value_cards_server <- function(id, df) {

  shiny::moduleServer(
    id,

    function(input, output, session) {

      output$value_cards <- shiny::renderUI({

        df <- views_sessions(df)[["views_sessions_cards"]] %>%
          dplyr::mutate(actuals = as.character(actuals)) %>%
          dplyr::bind_rows(
            session_duration(df)[["session_duration_cards"]],
            bounce_rate(df)[["bounce_rate_cards"]]
          ) %>%
          dplyr::mutate(
            name = factor(name, levels = name)
          )
        div(
          class = "row",
          create_cards(df)
        )

      })

    }

  )

}
