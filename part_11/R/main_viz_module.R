main_viz_ui <- function(id) {
  ns <- shiny::NS(id)

  shiny::tagList(
    shiny::uiOutput(
      outputId = ns("first")
    )
  )
}

main_viz_server <- function(id, add_btn_clicked, header, df_web, last_panel, sc, what_df) {

  shiny::moduleServer(
    id,

    function(input, output, session) {

      # renders when app loads
      output$first <- shiny::renderUI({

        purrr::pmap(
          list(
            x = c("a", "b", "c", "e", "f"),
            y = c("Page Views", "Device Category", "Day of Week", "Bounce Rate", "Popular Posts"),
            z = c("ga", "ga", "ga", "ga", "ga")
          ),
          function(x, y, z) {
            google_analytics_viz(
              title = y,
              viz = y,
              btn_id = x,
              df = if (z == "ga") {
                df_web()
              } else {
                sc()
              },
              class_all = "delete",
              class_specific = paste0("class_", x),
              color = "danger"
            )
          }
        )
      })

      # run when we add visualization
      shiny::observeEvent(add_btn_clicked(), {

        print(add_btn_clicked())
        what_df_viz <- what_df[what_df %in% add_btn_clicked()] %>%
          names()

        # clicked id
        panel <- add_btn_clicked()

        panel_plot_item <-
          google_analytics_viz(
            title = header(),
            viz = header(),
            df = if(what_df_viz == "ga") {
              df_web()
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
      })

    }
  )
}
