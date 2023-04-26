visitor_map <- function(df) {

  df %>%
    dplyr::group_by(country_name) %>%
    dplyr::summarise(n = dplyr::n()) %>%
    dplyr::ungroup() -> total_countries

  pal <- leaflet::colorBin(
    palette = "Blues",
    domain = total_countries$n,
    n = 10,
    pretty = FALSE
  )

  geo <- geo %>%
    fuzzyjoin::regex_inner_join(total_countries, by = c("ADMIN" = "country_name")) %>%
    sf::st_as_sf()

  map <- geo %>%
    leaflet::leaflet(
    data = .,
    options = leaflet::leafletOptions(
      minZoom = 1, maxZoom = 1
    )
  ) %>%
    leaflet::addTiles() %>%
    leaflet::addPolygons(
      stroke = FALSE,
      smoothFactor = 0.2,
      fillOpacity = 1,
      color = ~pal(n),
      popup = ~paste0(country_name, ": ", as.character(n), " Views")
    )

  return(map)

}
