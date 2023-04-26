value_cards_ui <- function(id) {

  ns <- shiny::NS(id)

  shiny::tagList(
    shiny::uiOutput(outputId = ns("cards_output")),
  )

}


value_cards_server <- function(id, df) {

  shiny::moduleServer(
    id,

    function(input, output, session) {

      output$cards_output <- shiny::renderUI({
        html <- div(
          class = "row eq-height",
          shiny::tagList(
            time_series_pageviews(df)[['cards_views_sessions']] %>%
              dplyr::bind_rows(
                session_duration(df),
                bounce_rate(df)$cards_bounce_rate
              ) %>%
              dplyr::mutate(name = factor(name, levels = name)) %>%
              create_cards()
          )
        )
      })

    }

  )

}
