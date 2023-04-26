main_viz_ui <- function(id) {

  ns <- shiny::NS(id)

  shiny::tagList(
    shiny::uiOutput(outputId = ns("first_plots"))
  )

}

main_viz_server <- function(
    id, ga, sc, clicked_link, header, last_panel,
    action_btn, current_viz, auth, user,
    visualizations, deleted_plot, viz, ids_names, time_series
) {

  shiny::moduleServer(
    id,

    function(input, output, session) {

      shiny::observeEvent(c(action_btn(), auth()), {

        shiny::req(action_btn() == 1, auth())

        header_db <- viz[viz$user == user(), ][["main_page"]][[1]][["viz"]][[1]]
        ids_db <- viz[viz$user == user(), ][["main_page"]][[1]][["ids"]][[1]]
        x <- visualizations[visualizations %in% header_db]
        dfs_db <- x[order(match(x, header_db))] %>% names()
        insert_html <- purrr::pmap(
          list(
            x = ids_db,
            y = header_db,
            z = dfs_db
          ),
          function(x, y, z) {
            google_analytics_viz(
              class_specific = paste0("class_", x),
              header = y,
              unique_id = x,
              df = if(z == "ga") {
                ga()
              } else if(z == "sc"){
                sc()
              } else {
                time_series
              },
              viz = y
            )
          }
        )

        shiny::insertUI(
          selector = "#placeholder",
          where = "afterEnd",
          ui = insert_html
        )

      })

      shiny::observeEvent(action_btn(), {

        shiny::req(action_btn() > 1)

         what_df <- visualizations[visualizations %in% current_viz()] %>%
          names()

        plotly_plots <- purrr::map2(
          .x = current_viz(), .y = what_df,
          ~ switch_fn(
            viz = .x,
            df  = if(.y == "ga") {ga()} else if(.y == "sc"){sc()} else {time_series}
          )
        )

        css_selector <- current_viz() %>%
          stringr::str_replace_all(" ", ".") %>%
          paste0(".", .)

        purrr::map2(
          .x = css_selector, .y = plotly_plots,
          ~ shiny::insertUI(
            selector = .x,
            where = "afterBegin",
            ui = .y
          )
        )


      })

      shiny::observeEvent(deleted_plot(), {

        deleted_header <- ids_names[ids_names == deleted_plot()] %>% names()

        connection$con_visualizations$update(
          query  = stringr::str_glue('{{"user": "{user()}"}}'),
          update = stringr::str_glue('{{"$pull":{{"main_page.0.viz": "{deleted_header}", "main_page.0.ids": "{deleted_plot()}"}}}')
        )

        connection$con_visualizations$update(
          query  = stringr::str_glue('{{"user": "{user()}"}}'),
          update = stringr::str_glue('{{"$push":{{"sidebar.0.viz": "{deleted_header}", "sidebar.0.ids": "{deleted_plot()}"}}}')
        )

      })


      shiny::observeEvent(clicked_link(), {

        what_df_to_use <- what_df[what_df %in% clicked_link()] %>%
          names()
        print(what_df_to_use)

        plot <- google_analytics_viz(
          class_specific = paste0("class_", clicked_link()),
          header = header(),
          unique_id = clicked_link(),
          df = if(what_df_to_use == "ga") {
            ga()
          } else if(what_df_to_use == "sc") {
            sc()
          } else {
            time_series
          },
          viz = header()
        )

        css_selector <- ifelse(
          last_panel() ==  "#placeholder",
          "#placeholder",
          paste0(".", last_panel())
        )

        shiny::insertUI(
          selector = css_selector,
          where = 'afterEnd',
          ui = plot
        )

        connection$con_visualizations$update(
          query  = stringr::str_glue('{{"user": "{user()}"}}'),
          update = stringr::str_glue('{{"$push":{{"main_page.0.viz": "{header()}", "main_page.0.ids": "{clicked_link()}"}}}')
        )

        connection$con_visualizations$update(
          query  = stringr::str_glue('{{"user": "{user()}"}}'),
          update = stringr::str_glue('{{"$pull":{{"sidebar.0.viz": "{header()}", "sidebar.0.ids": "{clicked_link()}"}}}')
        )

      })

    }

  )

}
