# start ui module
data_ui <- function(id) {
  ns <- shiny::NS(id)

  shiny::tagList(
    br(),
    br(),

    div(
      class = "row text-center",
      div(
        id = "get-date",
        class = "col-xl-3 col-md-3 col-sm-3 col-lg-3 text-center",
        style = "padding-top: 20px;",
        shiny::actionLink(
          inputId = ns("toggle_date"),
          label = "",
          icon = shiny::icon("angle-down")
        ),
        div(
          style = "padding: 10px;",
          id = ns("show_dates"),
          shiny::dateRangeInput(
            inputId = ns("google_data"),
            label = "Choose Time Frame",
            start = "2021-01-31",
            end = "2021-03-19",
            min = "2019-01-19",
            max = "2021-03-19",
            width = "100%"
          ),
          actionButton(
            inputId = ns("go"),
            label = "",
            icon = shiny::icon("filter")
          )
        ) %>% shinyjs::hidden()
      ),
      div(
        class = "col-xl-6 col-md-6 col-sm-6 col-lg-6",
        h1("Google Analytics Dashboard")
      ),
      div(
        id = "slide",
        class = "col-xl-3 col-md-3 col-sm-3 col-lg-3",
        style = "padding-top: 20px;",
        shiny::actionLink(
          inputId = "open",
          label = "",
          icon = shiny::icon("bars"),
          onclick = "open_sidebar()"
        )
      )
    ) %>%
      div(class = 'container')
  )

}

# start server module
data_server <- function(id) {
  shiny::moduleServer(
    id,

    function(input, output, session) {

      # toggle dates and filter icon
      shiny::observeEvent(input$toggle_date, {
        shinyjs::toggle(id = "show_dates", anim = TRUE)
      })

      # shinyjs::click(id  = "go")

      data <- shiny::reactive({

        date_1 <- input$google_data[1] %>% lubridate::ymd()
        date_2 <- input$google_data[2] %>% lubridate::ymd()
        int <- lubridate::interval(date_1, date_2)

        web_data <- readr::read_csv(here::here("data/web_data.csv")) %>%
          dplyr::filter(date %within% int)
        web_data_c <- readr::read_csv(here::here("data/search_console.csv"))%>%
          dplyr::filter(date %within% int)

        return(
          list(
            web_data = web_data,
            web_data_c = web_data_c
          )
        )

      })

      return(
        list(
          web_data_c = shiny::reactive(data()$web_data_c),
          web_data   = shiny::reactive(data()$web_data)
        )
      )
    }
  )
}
