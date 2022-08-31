library(shiny)
library(tidyverse)
library(plotly)

list.files(here::here("part_2/R")) %>%
    here::here("part_2/R", .) %>%
    purrr::walk(~source(.))

# Define UI for application that draws a histogram
ui <- fluidPage(

    br(),
    br(),

    div(id = "placeholder"),
    shiny::tagList(
        shiny::uiOutput(
            outputId = "first"
        )
    ),

    shiny::includeScript(here::here("part_2/www/scripts.js"))

)

# Define server logic required to draw a histogram
server <- function(input, output) {


    output$first <- shiny::renderUI({

        pmap(
            list(x = c("a", "b", "c"), y = c("Viz 1", "Viz 2", "Viz 3")),
            function(x, y) {
                google_analytics_viz(
                    title = y,
                    viz = y,
                    btn_id = x,
                    df = NULL,
                    class_all = "delete",
                    class_specific = paste0("class_", x),
                    color = "danger"
                )
            }
        )
    })

    # run when we add visualization
    shiny::observeEvent(input$add_btn_clicked, {

        # clicked id
        panel <- input$add_btn_clicked

        panel_plot_item <-
            google_analytics_viz(
                title = input$header,
                viz = NULL,
                df = NULL,
                btn_id = panel,
                class_all = "delete",
                class_specific = paste0("class_", panel),
                color = "danger"
            )

        css_selector <- ifelse(input$last_panel == "#placeholder",
                               "#placeholder",
                               paste0(".", input$last_panel)
        )

        shiny::insertUI(
            selector = css_selector,
            "afterEnd",
            ui = panel_plot_item
        )
    })

}

# Run the application
shinyApp(ui = ui, server = server)
