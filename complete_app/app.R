library(shiny)
library(tidyverse)
library(plotly)
library(here)
library(lubridate)
library(geojsonsf)
library(geojsonsf)
library(leaflet)
library(fuzzyjoin)
library(sf)
library(shinybusy)
library(knitr)
library(kableExtra)
library(shinyauthr)
library(mongolite)
library(config)
library(modeltime)

connection <<- mongo_db_connection()
user_base <- connection$user_base$find()

viz <- connection$con_visualizations$find() %>%
  dplyr::tibble()

time_series <- readr::read_csv(here::here("ga_dashboard/data/time_series.csv"))
web_data <- readr::read_csv(here::here("ga_dashboard/data/web_data.csv"))
web_data_c <- readr::read_csv(here::here("ga_dashboard/data/search_console.csv"))
geo <<- readr::read_rds(here::here("ga_dashboard/data/map.rds"))

what_df <<- c("a", "b", "c", "d", "e", "f", "g", "h") %>%
  purrr::set_names(c("ga", "ga", "ga", "ga", "ga", "sc","ga", "time_series"))
visualizations <<- c("Page Views", "Device Category", "Session Duration", "Channel Groupings", "Bounce Rate", "Visitor Map",  "Most Popular Posts", "Time Series") %>%
  purrr::set_names(c("ga", "ga", "ga", "ga", "ga", "sc", "ga", "time_series"))
ids_names <- c("a", "b", "c", "d", "e", "f", "g", "h") %>%
  purrr::set_names(c("Page Views", "Device Category", "Session Duration", "Channel Groupings", "Bounce Rate", "Visitor Map",  "Most Popular Posts", "Time Series"))

list.files("ga_dashboard/R") %>%
  here::here("ga_dashboard/R", .) %>%
  purrr::walk(
    ~source(.)
  )


ui <- fluidPage(

  shinyjs::useShinyjs(),
  shinyjs::extendShinyjs(here::here("ga_dashboard/www/scripts.js"), functions = c("remove_plotly_plots")),
  shiny::includeCSS(here::here("ga_dashboard/www/styles.css")),

  # add login panel UI function
  shinyauthr::loginUI(id = "login"),

  br(),
  br(),
  br(),

  div(
    id = "show-page-content",
    get_data_ui(id = "get_data"),

    sidebar_ui(id = "sidebar"),

    br(),
    br(),
    br(),
    br(),
    br(),

    value_cards_ui(id = "value-cards"),
    shiny::uiOutput(outputId = "value_cards"),

    div(id = 'placeholder'),

    main_viz_ui(id = "main_viz")
  ) %>% shinyjs::hidden(),

  shiny::includeScript(here::here("ga_dashboard/www/scripts.js"))


)

server <- function(input, output) {

  shiny::observe({
    shiny::req(credentials()$user_auth)
    shinyjs::show(id = "show-page-content")
  })

  # call login module supplying data frame,
  # user and password cols and reactive trigger
  credentials <- shinyauthr::loginServer(
    id = "login",
    data = user_base,
    user_col = user,
    pwd_col = password,
    cookie_logins = TRUE,
    sessionid_col = sessionid,
    cookie_getter = get_sessionids_from_db,
    cookie_setter = add_sessionid_to_db,
    log_out = reactive(logout_init())
  )

  # call the logout module with reactive trigger to hide/show
  logout_init <- shinyauthr::logoutServer(
    id = "logout",
    active = reactive(credentials()$user_auth)
  )

  value_cards_server(id = "value-cards", df = web_data)

  df_filtered_dates <- get_data_server(
    id         = "get_data",
    web_data   = web_data,
    web_data_c = web_data_c,
    auth       = shiny::reactive(credentials()$user_auth)
  )

  main_viz_server(
    id = "main_viz",
    ga = df_filtered_dates$ga,
    sc = df_filtered_dates$sc,
    time_series = time_series,
    clicked_link = shiny::reactive(input$clicked_link),
    header       = shiny::reactive(input$header),
    last_panel   = shiny::reactive(input$last_panel),
    action_btn   = df_filtered_dates$action_btn,
    current_viz  = shiny::reactive(input$current_viz),
    auth         = shiny::reactive(credentials()$user_auth),
    user         = shiny::reactive(credentials()$info[["user"]]),
    visualizations = visualizations,
    deleted_plot = shiny::reactive(input$deleted_plot),
    viz = viz,
    ids_names = ids_names
  )

  sidebar_server(id = "sidebar", user = shiny::reactive(credentials()$info[["user"]]), viz = viz)

}

# Run the application
shinyApp(ui = ui, server = server)
