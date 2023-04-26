create_cards <- function(df) {

  res <- df %>%
    dplyr::group_split(
      name
    ) %>%
    purrr::map(
      .x = .,
      ~ div(
        class = "col-xs-12 col-md-3 col-lg-3 col-sm-3",
        style = "display:flex;",
        div(
          class = "panel panel-default shadow",
          style = "margin: 5px; width: 100%",
          div(
            class = "panel-body",
            style = "display: flex;",
            div(
              style = "color: black;",
              h1(.x[["actuals"]]),
              div(
                style = "color: grey;",
                h4(.x[["name"]])
              ),
              div(
                style = stringr::str_glue("color: {.x[['color']]};"),
                p(
                  shiny::icon(paste0("arrow-", .x[["arrow"]])),
                  paste0(.x[["value"]], "%")
                )
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

    return(res)

}
