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
          list(
            className = "nowrap", width = "100px", targets = "_all", height = "400px"
          )
        )
      )
    ) -> data_table

  return(data_table)
}
