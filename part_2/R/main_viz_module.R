main_viz_ui <- function(id) {
  ns <- shiny::NS(id)

  shiny::tagList(
    shiny::uiOutput(
      outputId = ns("first")
    ) %>% shinycssloaders::withSpinner(
      size = 8, image = "google_spinner.gif"
    )
  )
}

main_viz_server <- function(id, data_btn, ga, sc, js_btn,
                            what_viz, last_panel, get_current_viz,
                            auth, db_viz, user, pass, delete_db) {
  shiny::moduleServer(
    id,

    function(input, output, session) {
      ns <- session$ns
      rv <- shiny::reactiveValues()

      # runs when app is opened and when data changes
      output$first <- shiny::renderUI({
        shiny::req(render_logical())
        purrr::pmap(
          list(x = rv$x, y = names(rv$x), z = rv$dfs),

          function(x, y, z) {
            google_analytics_viz(
              title = y,
              viz = y,
              df = if (z == "ga") {
                ga()
              } else {
                sc()
              },
              btn_id = x,
              class_all = "delete",
              class_specific = paste0("class_", x),
              color = "danger"
            )
          }
        )
      })

      shiny::observeEvent(delete_db(), {

        # delete viz
        con$update(
          query = rv$creds,
          update = paste0('{"$pull":{"viz": "', delete_db(), '" }}')
        )
      })

      # run when we add visualization
      shiny::observeEvent(js_btn(), {
        shiny::req(auth())
        panel <- js_btn()
        rv$single_viz <- unname(what_df[names(what_df) %in% what_viz()])

        panel_plot_item <-
          google_analytics_viz(
            title = what_viz(),
            viz = what_viz(),
            df = if (rv$single_viz == "ga") {
              ga()
            } else {
              sc()
            },
            btn_id = panel,
            class_all = "delete",
            class_specific = paste0("class_", panel),
            color = "danger"
          )

        css_selector <- ifelse(last_panel() == "#placeholder",
                               "#placeholder",
                               paste0(".", last_panel())
        )

        shiny::insertUI(
          selector = css_selector,
          "afterEnd",
          ui = panel_plot_item
        )

        # add viz
        con$update(
          query = rv$creds,
          update = paste0('{"$push":{"viz": "', panel, '"}}')
        )
      })
    }
  )
}
