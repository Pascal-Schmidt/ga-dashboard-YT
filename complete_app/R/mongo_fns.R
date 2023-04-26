mongo_db_connection <- function() {
  config <- config::get()

  user_mongo <- config$user
  password_mongo <- config$password
  cluster <- config$cluster
  db <- config$db
  collections <- config$collection %>%
    stringr::str_split(' ') %>%
    unlist()
  db_connect_str <- stringr::str_glue("mongodb+srv://{user_mongo}:{password_mongo}@{cluster}/{db}?retryWrites=true&w=majority")

  connection <- collections %>%
    purrr::map(
      .x = .,
      ~ mongolite::mongo(
        collection = .x,
        db = db,
        url = db_connect_str
      )
    )

  return(
    list(
      user_base = connection[[1]],
      logins = connection[[2]],
      con_visualizations = connection[[3]]
    )
  )

}


cookie_expiry <- 7 # Days until session expires

add_sessionid_to_db <- function(user, sessionid, con = connection$logins) {
  tibble(user = user, sessionid = sessionid, login_time = as.character(now())) %>%
    con$insert()
}

get_sessionids_from_db <- function(con = connection$logins, expiry = cookie_expiry) {
  con$find() %>%
    mutate(login_time = ymd_hms(login_time)) %>%
    as_tibble() %>%
    filter(login_time > now() - days(expiry))
}
