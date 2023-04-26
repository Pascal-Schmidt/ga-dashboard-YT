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
library(config)
library(mongolite)

# df <- dplyr::tibble(
#   main_page = dplyr::tibble(
#     viz = list(c("Page Views", "Device Category", "Day of Week", "Channels")),
#     ids = list(c("a", "b", "c", "d")),
#     df  = list(c("ga", "ga", "ga", "ga"))
#   ) %>% list(),
#   sidebar = dplyr::tibble(
#     viz = list(c("Bounce Rate", "Popular Posts", "Visitor Map")),
#     ids = list(c("e", "f", "g")),
#     df  = list(c("ga", "ga", "sc"))
#   ) %>% list()
# ) %>% replicate(3, ., simplify = FALSE) %>%
#   dplyr::bind_rows() %>%
#   dplyr::bind_cols(
#     user = connections$con_users$find()$user, .
#   )

# connections$con_visualizations$update(
#   query = '{"user": "pascal"}',
#   update = '{"$pull":{"main_page.0.viz": "vvv"}}'
# )

connections <<- connect_to_db()
viz <<- connections$con_visualizations$find() %>%
  dplyr::as_tibble()
user_base <<- connections$con_users$find()
cookie_expiry <<- 7 # Days until session expires

web_data <- readr::read_csv(here::here("GA_dashboard/part_15/data/web_data.csv"))
web_data_c <- readr::read_csv(here::here("GA_dashboard/part_15/data/search_console.csv"))

geo <- readr::read_rds(here::here("GA_dashboard/part_15/data/map.rds"))

visualizations <<- c("a", "b", "c", "d", "e", "f", "g") %>%
  purrr::set_names(c("Page Views", "Device Category", "Day of Week", "Channels", "Bounce Rate", "Popular Posts", "Visitor Map"))
what_df <- c("a", "b", "c", "d", "e", "f", "g") %>%
  purrr::set_names(c("ga", "ga", "ga", "ga", "ga", "ga", "sc"))

list.files(here::here("R")) %>%
  here::here("R", .) %>%
  purrr::walk(~source(.))

# Define UI for application that draws a histogram
ui <- fluidPage(

    shinyjs::useShinyjs(),
    shinyjs::extendShinyjs(script = here::here("GA_dashboard/part_15/www/scripts.js"), functions = c("remove_plots_date_change")),
    shiny::includeCSS(here::here("GA_dashboard/part_15/www/styles.css")),

    loginUI(id = "login", cookie_expiry = cookie_expiry),
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

    shiny::includeScript(here::here("GA_dashboard/part_15/www/scripts.js"))

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
    cookie_logins = TRUE,
    sessionid_col = sessionid,
    cookie_getter = get_sessionids_from_db,
    cookie_setter = add_sessionid_to_db,
    sodium_hashed = FALSE,
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
    auth            = shiny::reactive(credentials()$user_auth),
    user            = shiny::reactive(credentials()$info[["user"]]),
    main_page_info  = viz
  )

  sidebar_server(
    id   = "sidebar",
    user = shiny::reactive(credentials()$info[["user"]]),
    sidebar_info = viz
  )

}

# Run the application
shinyApp(ui = ui, server = server)
