main_viz_ui <- function(id) {
  ns <- shiny::NS(id)

  shiny::tagList(
    shiny::uiOutput(
      outputId = ns("first")
    )
  )
}

main_viz_server <- function(id, add_btn_clicked, header, df_web, last_panel) {

  shiny::moduleServer(
    id,

    function(input, output, session) {

      # renders when app loads
      output$first <- shiny::renderUI({

        purrr::pmap(
          list(x = c("a", "b", "c"), y = c("Page Views", "Device Category", "Day of Week")),
          function(x, y) {
            google_analytics_viz(
              title = y,
              viz = y,
              btn_id = x,
              df = df_web,
              class_all = "delete",
              class_specific = paste0("class_", x),
              color = "danger"
            )
          }
        )
      })

      # run when we add visualization
      shiny::observeEvent(add_btn_clicked(), {

        # clicked id
        panel <- add_btn_clicked()

        panel_plot_item <-
          google_analytics_viz(
            title = header(),
            viz = header(),
            df = df_web,
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
      })

    }
  )
}
