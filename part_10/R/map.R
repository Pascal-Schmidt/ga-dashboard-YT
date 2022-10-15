map <- function(df) {
  df %>%
    dplyr::group_by(country_name) %>%
    dplyr::summarise(total = dplyr::n()) %>%
    dplyr::ungroup() -> country_count

  pal <- leaflet::colorBin(
    palette = "Blues",
    n = 10,
    pretty = F,
    domain = country_count$total
  )

  geo <- geojsonsf::geojson_sf("https://raw.githubusercontent.com/eparker12/nCoV_tracker/master/input_data/50m.geojson") %>%
    as.data.frame()

  geo <- geo %>%
    fuzzyjoin::regex_inner_join(country_count, by = c(ADMIN = "country_name")) %>%
    sf::st_as_sf()

  geo %>%
    leaflet::leaflet(
      data = .,
      options = leafletOptions(
        minZoom = 1, maxZoom = 1
      )
    ) %>%
    leaflet::addTiles() %>%
    leaflet::addPolygons(
      stroke = FALSE,
      smoothFactor = 0.2,
      fillOpacity = 1,
      color = ~ pal(total),
      popup = ~ paste0(country_name, ": ", as.character(total), " Views")
    ) -> map

  return(map)
}
