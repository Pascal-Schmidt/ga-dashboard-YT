popular_posts_table <- function(df) {
  df %>%
    dplyr::filter(!is.na(page_path)) %>%
    dplyr::group_by(`Page URL` = page_path) %>%
    dplyr::summarise(Views = sum(pageviews)) %>%
    dplyr::ungroup() %>%
    dplyr::arrange(desc(Views)) %>%
    as.data.frame() %>%
    .[1:10, ] %>%
    knitr::kable(format = "html") %>%
    kableExtra::kable_styling(bootstrap_options = c("striped", "hover")) %>%
    shiny::HTML() -> data_table

  return(data_table)
}
