session_duration <- function(df) {

  temp <- df %>%
    dplyr::group_by(date) %>%
    dplyr::summarise(
      session_duration = mean(session_duration) %>%
        round(2)
    )

  actual_duration <- temp %>%
    dplyr::arrange(desc(date)) %>%
    dplyr::slice(2) %>%
    .[, 2] %>%
    dplyr::pull()

  duration <- temp %>%
    dplyr::arrange(desc(date)) %>%
    dplyr::slice(2:3) %>%
    dplyr::mutate(
      session_duration = ((session_duration[1] - session_duration[2])/session_duration[2]*100) %>%
        round(2)
    ) %>%
    dplyr::select(-date) %>%
    .[1, ] %>%
    tidyr::pivot_longer(dplyr::everything()) %>%
    dplyr::mutate(
      icon = 'clock',
      name = "Session Duration"
    ) %>%
    dplyr::mutate(
      arrow = ifelse(value < 0, "down", "up"),
      color = ifelse(value < 0, "red", "green"),
      actuals = actual_duration %>% paste("Sec")
    )

  return(duration)
}
