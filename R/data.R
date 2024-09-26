#' Region Maps
#'
#' Simple feature collection with 4 features and 4 fields
#'
#' @format ## `region_map`

#' \describe{
#'   \item{region_name}{Region name}
#'   \item{geometry}{geometry}
#'   \item{cent_long}{Longitude of centroid}
#'   \item{cent_lat}{Latitude of centroid}
#'   ...
#' }
#' @source <https://www.vic.gov.au/regional-model-department-education>
"region_map"

#' Area Maps
#'
#' Simple feature collection with 4 features and 4 fields
#'
#' @format ## `area_map`

#' \describe{
#'   \item{region_name}{Region name}
#'   \item{area_name}{Area name}
#'   \item{geometry}{geometry}
#'   \item{cent_long}{Longitude of centroid}
#'   \item{cent_lat}{Latitude of centroid}
#'   ...
#' }
#' @source <https://www.vic.gov.au/regional-model-department-education>
"area_map"


#' Region Table
#'
#' A tibble of with 3 columns and 79 rows.
#'
#' @format ## `region_tbl`

#' \describe{
#'   \item{region_name}{Region name, with four values}
#'   \item{area_name}{Area name, with 17 values}
#'   \item{lga_name}{Local government area name, with 79 values}
#'   \item{cent_long}{Longitude of centroid}
#'   \item{cent_lat}{Latitude of centroid}
#'   ...
#' }
#' @source <https://www.vic.gov.au/regional-model-department-education>
"region_tbl"


