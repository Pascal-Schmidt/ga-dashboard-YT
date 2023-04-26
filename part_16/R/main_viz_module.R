main_viz_ui <- function(id) {
  ns <- shiny::NS(id)

  shiny::tagList(
    div(id = "placeholder")
  )
}

main_viz_server <- function(
    id, add_btn_clicked, header, df_web, last_panel, visualizations,
    sc, what_df, filter_btn, current_viz, auth, user, main_page_info, delete_db_id
) {

  shiny::moduleServer(
    id,

    function(input, output, session) {

      # we only run this function once when the user starts the application
      shiny::observeEvent(c(filter_btn(), auth()), {

        shiny::req(filter_btn() == 1, sc(), df_web(), auth())
        df <- main_page_info[main_page_info$user == user(), ]$main_page[[1]]
        df_for_plots <- what_df[what_df %in% df$ids[[1]]]
        df_for_plots <- df_for_plots[order(match(df_for_plots, df$ids[[1]]))] %>% names()
        html_insert <- purrr::pmap(
          list(
            x = df$ids[[1]],
            y = df$viz[[1]],
            z = df_for_plots
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

        shiny::insertUI(
          selector = "#placeholder",
          "afterEnd",
          ui = html_insert
        )

      })

      # this function gets run after the user updates the dates
      # it removes the plotly plots and substitutes them with the new data
      shiny::observeEvent(filter_btn(), {

        # only fires when action button has been clicked more than once
        shiny::req(filter_btn() > 1)

        what_df_viz <- visualizations[names(visualizations) %in% current_viz()] %>%
          unname() %>%
          {what_df[what_df %in% .]} %>%
          names()

        viz <- what_df_viz %>%
          purrr::map2(
            .x = current_viz(), .y = .,
            ~ switch_fn(
              .x, if(.y == "ga") {df_web()} else {sc()}
            )
          )

        classes_for_viz <- current_viz() %>%
          stringr::str_replace_all(" ", '.') %>% paste0(".", .)

        purrr::map2(
          .x = classes_for_viz, .y = viz,
          ~ shiny::insertUI(
            selector = .x,
            "beforeEnd",
            ui = .y
          )
        )

      }, ignoreInit = T)

      # delete viz in db when removed inside the app
      shiny::observeEvent(delete_db_id(), {

        header_mongo <- visualizations[visualizations %in% delete_db_id()] %>%
          names()

        df_mongo <- what_df[what_df %in% delete_db_id()] %>%
          names()

        # delete viz from mongo db main page
        connections$con_visualizations$update(
          query  = stringr::str_glue('{{"user": "{user()}"}}'),
          update = stringr::str_glue('{{"$pull":{{"main_page.0.viz": "{header_mongo}", "main_page.0.ids": "{delete_db_id()}"}}}')
        )

        # add viz to mongo db sidebar
        connections$con_visualizations$update(
          query  = stringr::str_glue('{{"user": "{user()}"}}'),
          update = stringr::str_glue('{{"$push":{{"sidebar.0.viz": "{header_mongo}", "sidebar.0.ids": "{delete_db_id()}"}}}')
        )

      })

      # run when we add visualization
      shiny::observeEvent(add_btn_clicked(), {

        what_df_viz <- what_df[what_df %in% add_btn_clicked()] %>%
          names()

        # clicked id
        panel <- add_btn_clicked()

        print(what_df_viz)
        print(panel)
        print(header())

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

        css_selector <- ifelse(
          last_panel() == "#placeholder",
          "#placeholder",
          paste0(".", last_panel()
          )
        )

        shiny::insertUI(
          selector = css_selector,
          "afterEnd",
          ui = panel_plot_item
        )

        # add viz to mongo db main page
        connections$con_visualizations$update(
          query  = stringr::str_glue('{{"user": "{user()}"}}'),
          update = stringr::str_glue('{{"$push":{{"main_page.0.viz": "{header()}", "main_page.0.ids": "{panel}"}}}')
        )

        # add viz to mongo db main page
        connections$con_visualizations$update(
          query  = stringr::str_glue('{{"user": "{user()}"}}'),
          update = stringr::str_glue('{{"$pull":{{"sidebar.0.viz": "{header()}", "sidebar.0.ids": "{panel}"}}}')
        )

      })

    }
  )
}
