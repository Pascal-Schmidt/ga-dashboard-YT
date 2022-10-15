popular_posts_table <- function(df) {
  df %>%
    dplyr::group_by(page_path) %>%
    dplyr::summarise(Views = sum(pageviews)) %>%
    dplyr::ungroup() %>%
    dplyr::arrange(desc(Views)) %>%
    as.data.frame() %>%
    .[1:25, ] %>%
    DT::datatable(
      options = list(
        autoWidth = TRUE,
        columnDefs = list(
          list(className = "nowrap", width = "100px", targets = "_all")
        )
      )
    ) -> data_table

  data_table <- div(
    style = "height: 400px; overflow-y: scroll; overflow-x: scroll;",
    data_table
  ) %>%
    shiny::tagList()

  return(data_table)
}
