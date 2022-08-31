library(shiny)
library(tidyverse)
library(plotly)


# Define UI for application that draws a histogram
ui <- fluidPage(

    br(),
    br(),

    shiny::tagList(

        # first viz
        div(
            class = "class_a",
            div(
                class = "col-md-6",
                div(
                    class = "panel panel-default",
                    div(
                        class = "panel-heading clearfix",
                        tags$h2("Visualization 1", class = "pull-left panel-title"),
                        div(
                            class = "pull-right",
                            shiny::actionButton(
                                inputId = "a",
                                label = "",
                                class = "btn-danger delete",
                                icon = shiny::icon("minus")
                            )
                        )
                    ),
                    div(
                        class = "panel-body",
                        plotly::plot_ly(mtcars, x = ~mpg, y = ~wt)
                    )
                )
            )
        ),

        # second viz
        div(
            class = "class_b",
            div(
                class = "col-md-6",
                div(
                    class = "panel panel-default",
                    div(
                        class = "panel-heading clearfix",
                        tags$h2("Visualization 2", class = "pull-left panel-title"),
                        div(
                            class = "pull-right",
                            shiny::actionButton(
                                inputId = "b",
                                label = "",
                                class = "btn-danger delete",
                                icon = shiny::icon("minus")
                            )
                        )
                    ),
                    div(
                        class = "panel-body",
                        plotly::plot_ly(mtcars, x = ~mpg, y = ~wt)
                    )
                )
            )
        ),

        # third viz
        div(
            class = "class_c",
            div(
                class = "col-md-6",
                div(
                    class = "panel panel-default",
                    div(
                        class = "panel-heading clearfix",
                        tags$h2("Visualization 3", class = "pull-left panel-title"),
                        div(
                            class = "pull-right",
                            shiny::actionButton(
                                inputId = "c",
                                label = "",
                                class = "btn-danger delete",
                                icon = shiny::icon("minus")
                            )
                        )
                    ),
                    div(
                        class = "panel-body",
                        plotly::plot_ly(mtcars, x = ~mpg, y = ~wt)
                    )
                )
            )
        )


    ),

    shiny::includeScript(here::here("part_1/www/scripts.js"))

)

# Define server logic required to draw a histogram
server <- function(input, output) {


}

# Run the application
shinyApp(ui = ui, server = server)
