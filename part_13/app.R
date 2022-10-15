library(shiny)
library(tidyverse)
library(plotly)
library(lubridate)
library(sf)
library(fuzzyjoin)
library(leaflet)
library(geojsonsf)
library(shinybusy)
library(shinyauthr)

# dataframe that holds usernames, passwords and other user data
user_base <- tibble::tibble(
  user = c("user1", "user2"),
  password = c("pass1", "pass2"),
  permissions = c("admin", "standard"),
  name = c("User One", "User Two")
)

web_data <- readr::read_csv(here::here("data/web_data.csv"))
web_data_c <- readr::read_csv(here::here("data/search_console.csv"))

geo <<- geojsonsf::geojson_sf("https://raw.githubusercontent.com/eparker12/nCoV_tracker/master/input_data/50m.geojson") %>%
  as.data.frame()

visualizations <<- c("a", "b", "c", "d", "e", "f", "g") %>%
  purrr::set_names(c("Page Views", "Device Category", "Day of Week", "Channels", "Bounce Rate", "Popular Posts", "Visitor Map"))
what_df <- c("a", "b", "c", "d", "e", "f", "g") %>%
  purrr::set_names(c("ga", "ga", "ga", "ga", "ga", "ga", "sc"))

list.files(here::here("GA_dashboard/part_13/R")) %>%
    here::here("GA_dashboard/part_13/R", .) %>%
    purrr::walk(~source(.))

# Define UI for application that draws a histogram
ui <- fluidPage(

    shinyjs::useShinyjs(),
    shinyjs::extendShinyjs(script = here::here("GA_dashboard/part_13/www/scripts.js"), functions = c("remove_plots_date_change")),
    shiny::includeCSS(here::here("GA_dashboard/part_13/www/styles.css")),

    loginUI(id = "login"),
    div(class = "pull-right", shinyauthr::logoutUI(id = "logout")),
    div(
      id = "display_content",
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
      )
    ) %>% shinyjs::hidden(),

    shiny::includeScript(here::here("GA_dashboard/part_13/www/scripts.js"))

)

# Define server logic required to draw a histogram
server <- function(input, output) {

  # call login module supplying data frame,
  # user and password cols and reactive trigger
  credentials <- shinyauthr::loginServer(
    id = "login",
    data = user_base,
    user_col = user,
    pwd_col = password,
    log_out = reactive(logout_init())
  )

  # call the logout module with reactive trigger to hide/show
  logout_init <- shinyauthr::logoutServer(
    id = "logout",
    active = reactive(credentials()$user_auth)
  )

  shiny::observe({
    req(credentials()$user_auth)
    shinyjs::show(id = "display_content")
  })

  shiny::observe({
    req(!credentials()$user_auth)
    shinyjs::hide(id = "display_content")
  })

  value_cards_server(id = "cards", df = web_data)

  df <- data_server(
    id          = 'get-data',
    web_data_ga = web_data,
    sc          = web_data_c,
    auth        = shiny::reactive(credentials()$user_auth)
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
    current_viz     = shiny::reactive(input$viz_on_page),
    auth            = shiny::reactive(credentials()$user_auth)
  )

  sidebar_server(id = "sidebar")

}

# Run the application
shinyApp(ui = ui, server = server)
