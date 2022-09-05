library(shiny)
library(tidyverse)
library(plotly)

web_data <- readr::read_csv(here::here("data/web_data.csv"))
list.files(here::here("part_5/R")) %>%
    here::here("part_5/R", .) %>%
    purrr::walk(~source(.))

# Define UI for application that draws a histogram
ui <- fluidPage(

    br(),
    br(),

    div(id = "placeholder"),
    shiny::tagList(
        main_viz_ui("main_viz")
    ),

    shiny::includeScript(here::here("part_5/www/scripts.js"))

)

# Define server logic required to draw a histogram
server <- function(input, output) {

    main_viz_server(
        id = "main_viz",
        add_btn_clicked = shiny::reactive(input$add_btn_clicked),
        header          = shiny::reactive(input$header),
        df_web          = web_data,
        last_panel      = shiny::reactive(input$last_panel)
    )

}

# Run the application
shinyApp(ui = ui, server = server)
