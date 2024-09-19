## code to prepare `vic_edu_regions` dataset goes here

library(tidyverse)
library(strayr)
library(sf)
library(rvest)
library(sfheaders)

# Read table of regions, areas, and lgas from departmental website
region.text =
 read_html(
  "https://www.vic.gov.au/regional-model-department-education") |>
 html_elements("tbody") |>
 html_text()

# get areas
area.text =
  read_html(
    "https://www.vic.gov.au/regional-model-department-education") |>
  html_elements("td strong") |>
  html_text() |>
  as_tibble_col("area_name") |>
  filter(!str_detect(area_name,"Offices"))


# Use above to create region table
region_tbl =
  region.text |>
  str_split(pattern = "\n\t\t") |>
  unlist() |>
  as_tibble_col() |>
  # First get region names, which all contain "Victoria"
  mutate(
   region_name = str_extract(value, ".*Victoria")
   ) |>
  fill(region_name) |>
  filter(!str_detect(value,region_name)) |>
  # Then get LGA names, which are lists with commas
  mutate(
   lga_name = str_extract(value,".*,.*"),
   lga_name = str_remove_all(lga_name,"Offices")) |>
  # Then get area names
  mutate(
   area_name = str_extract(lga_name,str_flatten(area.text$area_name,"|")),
   area_name = coalesce(area_name,value)
   ) |>
  # Tidy data
  filter(area_name!=lga_name|is.na(lga_name)) |>
  mutate(area_name = lag(area_name))  |>
  filter(!is.na(lga_name)) |>
  select(contains("name")) |>
  mutate_all(\(x) str_remove_all(x,"\t")) |>
  mutate(lga_name=str_split(lga_name,", ")) |>
  unnest(lga_name) |>
  mutate(lga_name=  str_remove(lga_name, str_flatten(area.text$area_name,"|"))) |>
  select(region_name, area_name, lga_name)

usethis::use_data(region_tbl, overwrite = TRUE)

# Get lga sf objects using read_absmap
lga_map =
  read_absmap("lga2021", remove_year_suffix = TRUE) |>
  filter(state_code == 2) |>
  mutate(lga_name = str_remove(lga_name,"\\s\\(.*\\)"),
         lga_name = str_replace(lga_name,"Moreland","Merri-bek"))

# Create region_map
region_map =
  region_tbl |>
  left_join(lga_map) |>
  st_as_sf()  |>
  group_by(region_name) |>
  summarise() |>
  group_by(region_name) |>
  summarise()

# Save to data
usethis::use_data(region_map, overwrite = TRUE)

# Create area_map
area_map =
  region_tbl |>
  left_join(lga_map) |>
  st_as_sf()  |>
  group_by(region_name, area_name) |>
  summarise()

# Save to data
usethis::use_data(area_map, overwrite = TRUE)
