get_data_ui <- function(id) {

  ns <- shiny::NS(id)

  shiny::tagList(
    div(
      class = "row text-center",
      div(
        class = "col-sm-3 col-md-3 col-lg-3",
        style = "padding-top: 20px;",
        shiny::actionLink(
          inputId = ns("show_dates"),
          label = "",
          icon = shiny::icon("angle-down")
        ),
        div(
          id = ns("toggle_dates"),
          shiny::dateRangeInput(
            inputId = ns("choose_dates"),
            label = "",
            start = "2020-01-01",
            end = "2021-01-01",
            min = "2019-01-19",
            max = "2021-03-19",
            width = "100%"
          ),
          div(
            shiny::actionButton(
              inputId = ns("api_call"),
              label = "",
              icon = shiny::icon("filter")
            )
          )
        ) %>% shinyjs::hidden()
      ),
      div(
        class = "col-sm-6 col-md-6 col-lg-6",
        h1("Google Analytics Dashboard")
      ),
      div(
        class = "col-sm-3 col-md-3 col-lg-3",
        style = "padding-top: 20px;",
        shiny::actionLink(
          inputId = "open",
          label = "",
          icon = shiny::icon("bars"),
          onclick = "open_sidebar()"
        )
      )
    ) %>% div(class = "container")
  )

}


get_data_server <- function(id, web_data, web_data_c, auth) {

  shiny::moduleServer(
    id,

    function(input, output, session) {

      shiny::observeEvent(input$show_dates, {
        shinyjs::toggle(id = "toggle_dates", anim = TRUE)
      })

      shinyjs::click(id = "api_call")
      shiny::observeEvent(input$api_call, {

        shiny::req(input$api_call > 1)
        shinyjs::js$remove_plotly_plots()

      }, ignoreInit = TRUE)

      data <- shiny::eventReactive(c(input$api_call, auth()), {

        shiny::req(auth())
        shinybusy::show_modal_spinner(text = "Retrieving API data...")
        Sys.sleep(3)
        date_1 <- input$choose_dates[1] %>% lubridate::ymd()
        date_2 <- input$choose_dates[2] %>% lubridate::ymd()
        date_int <- lubridate::interval(date_1, date_2)

        web_data_filtered <- web_data %>%
          dplyr::filter(date %within% date_int)
        web_data_filtered_c <- web_data_c %>%
          dplyr::filter(date %within% date_int)
        shinybusy::remove_modal_spinner()

        return(
          list(
            ga = web_data_filtered,
            sc = web_data_filtered_c
          )
        )

      })

      return(
        list(
          ga = shiny::reactive(data()$ga),
          sc = shiny::reactive(data()$sc),
          action_btn = shiny::reactive(input$api_call)
        )
      )

    }

  )

}
