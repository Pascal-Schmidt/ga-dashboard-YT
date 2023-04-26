create_cards <- function(df) {

  df %>%
    dplyr::group_split(name) %>%
    purrr::map(
      .x = .,
      ~ div(
        class = "col-lg-3 col-md-3 col-lg-12",
        div(
          class = "panel panel-default",
          style = "display: flex;",
          div(
            class = "panel-body",
            style = "display: flex; width: 100%; margin: 5px;",
            div(
              style = "color: black;",
              h1(.x[["actuals"]]),
              div(
                style = "color: grey;",
                h4(.x[["name"]])
              ),
              div(
                style = stringr::str_glue('color: {.x[["color"]]}'),
                p(shiny::icon(paste0("arrow-", .x[["arrow"]])), .x[["value"]])
              )
            ),
            div(
              style = "font-size: 70px;
                   color: grey;
                   align-self: center;
                   margin: 0 auto;
                   margin-right: 10px;",
              shiny::icon(.x[["icon"]])
            )
          )
        )
      )
    )

}

