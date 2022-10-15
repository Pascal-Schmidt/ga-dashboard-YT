library(shiny)
library(tidyverse)
library(plotly)
library(lubridate)

web_data <- readr::read_csv(here::here("data/web_data.csv"))
web_data_c <- readr::read_csv(here::here("data/search_console.csv"))

list.files(here::here("GA_dashboard/part_10/R")) %>%
    here::here("GA_dashboard/part_10/R", .) %>%
    purrr::walk(~source(.))

# Define UI for application that draws a histogram
ui <- fluidPage(

    shinyjs::useShinyjs(),
    shiny::includeCSS(here::here("GA_dashboard/part_10/www/styles.css")),

    br(),
    br(),


    data_ui(id = "get-data"),
    sidebar_ui(id = 'sidebar'),

    br(),
    br(),
    br(),
    br(),
    br(),


    value_cards_ui(id = "cards"),

    br(),
    br(),
    br(),

    div(id = "placeholder"),


    shiny::tagList(
        main_viz_ui("main_viz")
    ),

    shiny::includeScript(here::here("GA_dashboard/part_10/www/scripts.js"))

)

# Define server logic required to draw a histogram
server <- function(input, output) {

  value_cards_server(id = "cards", df = web_data)

  df <- data_server(id = 'get-data')

  main_viz_server(
    id = "main_viz",
    add_btn_clicked = shiny::reactive(input$add_btn_clicked),
    header          = shiny::reactive(input$header),
    df_web          = df$web_data,
    last_panel      = shiny::reactive(input$last_panel)
  )

  sidebar_server(id = "sidebar")

}

# Run the application
shinyApp(ui = ui, server = server)
