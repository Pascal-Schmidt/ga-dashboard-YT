library(shiny)
library(tidyverse)
library(plotly)
library(lubridate)
library(sf)
library(fuzzyjoin)
library(leaflet)
library(geojsonsf)
library(shinybusy)
library(knitr)
library(kableExtra)

web_data <- readr::read_csv(here::here("data/web_data.csv"))
web_data_c <- readr::read_csv(here::here("data/search_console.csv"))

geo <<- geojsonsf::geojson_sf("https://raw.githubusercontent.com/eparker12/nCoV_tracker/master/input_data/50m.geojson") %>%
  as.data.frame()

visualizations <<- c("a", "b", "c", "d", "e", "f", "g") %>%
  purrr::set_names(c("Page Views", "Device Category", "Day of Week", "Channels", "Bounce Rate", "Popular Posts", "Visitor Map"))
what_df <- c("a", "b", "c", "d", "e", "f", "g") %>%
  purrr::set_names(c("ga", "ga", "ga", "ga", "ga", "ga", "sc"))

list.files(here::here("GA_dashboard/part_12/R")) %>%
    here::here("GA_dashboard/part_12/R", .) %>%
    purrr::walk(~source(.))

# Define UI for application that draws a histogram
ui <- fluidPage(

    shinyjs::useShinyjs(),
    shinyjs::extendShinyjs(script = here::here("GA_dashboard/part_12/www/scripts.js"), functions = c("remove_plots_date_change")),
    shiny::includeCSS(here::here("GA_dashboard/part_12/www/styles.css")),

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

    shiny::tagList(
        main_viz_ui("main_viz")
    ),

    shiny::includeScript(here::here("GA_dashboard/part_12/www/scripts.js"))

)

# Define server logic required to draw a histogram
server <- function(input, output) {

  value_cards_server(id = "cards", df = web_data)

  df <- data_server(
    id          = 'get-data',
    web_data_ga = web_data,
    sc          = web_data_c
  )

  main_viz_server(
    id = "main_viz",
    add_btn_clicked = shiny::reactive(input$add_btn_clicked),
    header          = shiny::reactive(input$header),
    df_web          = df$web_data,
    sc              = df$web_data_c,
    filter_btn      = df$filter_btn,
    last_panel      = shiny::reactive(input$last_panel),
    what_df         = what_df,
    current_viz     = shiny::reactive(input$viz_on_page)
  )

  sidebar_server(id = "sidebar")

}

# Run the application
shinyApp(ui = ui, server = server)
