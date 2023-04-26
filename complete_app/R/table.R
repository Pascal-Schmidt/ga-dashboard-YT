table <- function(df) {

  df %>%
    dplyr::filter(!is.na(page_path)) %>%
    dplyr::group_by(`Page URL` = page_path) %>%
    dplyr::summarise(
      views = sum(pageviews)
    ) %>%
    dplyr::ungroup() %>%
    dplyr::arrange(desc(views)) %>%
    dplyr::slice(1:20) %>%
    knitr::kable(format = "html") %>%
    kableExtra::kable_styling(bootstrap_options = c("striped", "hover")) %>%
    shiny::HTML() %>%
    div(id = "htmlwidget-") -> table

  return(table)

}
