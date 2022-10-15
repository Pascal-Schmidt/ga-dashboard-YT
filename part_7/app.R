library(shiny)
library(tidyverse)
library(plotly)

web_data <- readr::read_csv(here::here("data/web_data.csv"))
list.files(here::here("GA_dashboard/part_7/R")) %>%
    here::here("GA_dashboard/part_7/R", .) %>%
    purrr::walk(~source(.))

# Define UI for application that draws a histogram
ui <- fluidPage(

    shinyjs::useShinyjs(),
    shiny::includeCSS(here::here("GA_dashboard/part_7/www/styles.css")),

    br(),
    br(),


    div(
        class = "row text-center",
        div(
            class = "col-xl-3 col-md-3 col-sm-3 col-lg-3"
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
        div(class = 'container'),

    sidebar_ui(id = 'sidebar'),

    br(),
    br(),
    br(),
    br(),
    br(),

    div(id = "placeholder"),


    shiny::tagList(
        main_viz_ui("main_viz")
    ),

    shiny::includeScript(here::here("GA_dashboard/part_7/www/scripts.js"))

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

    sidebar_server(id = "sidebar")

}

# Run the application
shinyApp(ui = ui, server = server)
