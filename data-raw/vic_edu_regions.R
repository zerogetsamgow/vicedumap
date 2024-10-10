## code to prepare datasets
library(tidyverse)
library(rvest)
# Read table of regions, areas, and lgas from departmental website
region.text =
 rvest::read_html(
  "https://www.vic.gov.au/regional-model-department-education") |>
 rvest::html_elements("tbody") |>
 rvest::html_text()

# get areas
area.text =
  rvest::read_html(
    "https://www.vic.gov.au/regional-model-department-education") |>
  rvest::html_elements("td strong") |>
  rvest::html_text() |>
  tibble::as_tibble_col("area_name") |>
  dplyr::filter(!str_detect(area_name,"Offices"))



# Use above to create region table
region_tbl =
  region.text |>
  stringr::str_split(pattern = "\n\t\t") |>
  unlist() |>
  tibble::as_tibble_col() |>
  # First get region names, which all contain "Victoria"
  dplyr::mutate(
   region_name = str_extract(value, ".*Victoria")
   ) |>
  tidyr::fill(region_name) |>
  dplyr::filter(!str_detect(value,region_name)) |>
  # Then get LGA names, which are lists with commas
  dplyr::mutate(
   lga_name = str_extract(value,".*,.*"),
   lga_name = str_remove_all(lga_name,"Offices")) |>
  # Then get area names
  dplyr::mutate(
   area_name = str_extract(lga_name,str_flatten(area.text$area_name,"|")),
   area_name = coalesce(area_name,value)
   ) |>
  # Tidy data
  dplyr::filter(area_name!=lga_name|is.na(lga_name)) |>
  dplyr::mutate(area_name = lag(area_name))  |>
  dplyr::filter(!is.na(lga_name)) |>
  dplyr::select(contains("name")) |>
  dplyr::mutate_all(\(x) str_remove_all(x,"\t")) |>
  dplyr::mutate(lga_name=str_split(lga_name,", ")) |>
  tidyr::unnest(lga_name) |>
  dplyr::mutate(lga_name=  str_remove(lga_name, str_flatten(area.text$area_name,"|"))) |>
  dplyr::select(region_name, area_name, lga_name)

usethis::use_data(region_tbl, overwrite = TRUE)

# Get lga sf objects using read_absmap
lga_map =
  strayr::read_absmap(
    "lga2021",
    remove_year_suffix = TRUE) |>
  dplyr::filter(
    state_code == 2) |>
  dplyr::mutate(
    lga_name = str_remove(lga_name,"\\s\\(.*\\)"),
    lga_name = str_replace(lga_name,"Moreland","Merri-bek"))

# Create region_map
region_map =
  region_tbl |>
  dplyr::right_join(lga_map) |>
  sf::st_as_sf() |>
  dplyr::group_by(region_name) |>
  dplyr::summarise() |>
  dplyr::group_by(region_name) |>
  dplyr::summarise()

# Add cent_lat and cent_long variables

region_map =
  dplyr::bind_cols(
    region_map,
    region_map |>
      dplyr::group_by(region_name) |>
      # Centroid
      sf::st_centroid() |>
      # Get coordinates
      sf::st_coordinates() |>
      tibble::as_tibble() |>
      dplyr::rename("cent_long"=X,"cent_lat"=Y))

# Save to data
usethis::use_data(region_map, overwrite = TRUE)

# Create area_map
area_map =
  region_tbl |>
  dplyr::left_join(lga_map) |>
  sf::st_as_sf()  |>
  dplyr::group_by(region_name, area_name) |>
  dplyr::summarise()

# Add cent_lat and cent_long variables

area_map =
  dplyr::bind_cols(
    area_map,
    area_map |>
      dplyr::group_by(area_name) |>
      # Centroid
      sf::st_centroid() |>
      # Get coordinates
      sf::st_coordinates() |>
      tibble::as_tibble() |>
      dplyr::rename("cent_long"=X,"cent_lat"=Y))

# Save to data
usethis::use_data(area_map, overwrite = TRUE)
