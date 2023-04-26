connect_to_db <- function() {

  config <- config::get(file = here::here("GA_dashboard/part_15/config.yml"))

  collections <- config$collection %>%
    stringr::str_split(" ") %>%
    .[[1]]

  user_mongo <- config$user
  password_mongo <- config$password
  cluster <- config$cluster
  db <- config$db
  db_connect_str <- stringr::str_glue("mongodb+srv://{user_mongo}:{password_mongo}@{cluster}/{db}?retryWrites=true&w=majority")

  connections <- collections %>%
    purrr::map(
      .x = .,
      ~ mongolite::mongo(
        collection = .x,
        url = db_connect_str
      )
    )

  return(
    list(
      con_users  = connections[[1]],
      con_logins = connections[[2]],
      con_visualizations = connections[[3]]
    )
  )

}

add_sessionid_to_db <- function(user, sessionid, con = connections$con_logins) {
  dplyr::tibble(user = user, sessionid = sessionid, login_time = as.character(lubridate::now())) %>%
    con$insert()
}

get_sessionids_from_db <- function(con = connections$con_logins, expiry = cookie_expiry) {
  con$find() %>%
    dplyr::mutate(login_time = lubridate::ymd_hms(login_time)) %>%
    dplyr::as_tibble() %>%
    dplyr::filter(login_time > lubridate::now() - lubridate::days(expiry))
}
