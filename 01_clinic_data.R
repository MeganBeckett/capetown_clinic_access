###############################################################################################
#
# Get the locations of Cape Town's clinics
#
# Megan Beckett
#
###############################################################################################

# LIBRARIES -----------------------------------------------------------------------------------
library(dplyr)
library(stringr)
library(tidyr)
library(tidygeocoder)
library(ggmap)
library(rjson)
library(leaflet)

# URL = "https://www.capetown.gov.za/Family%20and%20home/See-all-City-facilities/Our-service-facilities/Clinics%20and%20healthcare%20facilities#Default=%7B%22k%22%3A%22%22%7D#f3f1fa77-4696-43e3-98a1-0926208efb6c=%7B%22k%22%3A%22%22%7D"

# GET DATA ------------------------------------------------------------------------------------
# Read in data from JSON file that copied from response query on website
page_1 <- fromJSON(file = "data/clinics_1.json")
page_2 <- fromJSON(file = "data/clinics_2.json")
page_3 <- fromJSON(file = "data/clinics_3.json")

# Extract relevant data from tree
clinics_1 <- page_1[[15]][[1]]$ResultTables[[1]]$ResultRows
clinics_2 <- page_2[[15]][[1]]$ResultTables[[1]]$ResultRows
clinics_3 <- page_3[[15]][[1]]$ResultTables[[1]]$ResultRows

# Convert to dataframe and combine
clinics_1 <- do.call(rbind, clinics_1) %>% as.data.frame() %>%
  select(Title, LocationOWSTEXT) %>%
  unnest(cols = c(Title, LocationOWSTEXT))

clinics_2 <- do.call(rbind, clinics_2) %>% as.data.frame() %>%
  select(Title, LocationOWSTEXT) %>%
  unnest(cols = c(Title, LocationOWSTEXT))

clinics_3 <- do.call(rbind, clinics_3) %>% as.data.frame() %>%
  select(Title, LocationOWSTEXT) %>%
  unnest(cols = c(Title, LocationOWSTEXT))

clinics <- bind_rows(clinics_1, clinics_2, clinics_3) %>%
  rename(title = Title,
         address = LocationOWSTEXT) %>%
  mutate(address = paste(address, "Cape Town, South Africa", sep = ", "))


# GEOCODING -----------------------------------------------------------------------------------
# Using {tidygeocoder} ------------------------------------------------------------------------
clinics_coords_tidy <- clinics %>%
  geocode(address)

# Lots of missing locations
clinics_missing_tidy <- clinics_coords %>%
  filter(is.na(lat))


# Using {ggmap} -------------------------------------------------------------------------------
# Register your API key.
# More info here: https://developers.google.com/maps/documentation/geocoding/get-api-key
register_google(key = Sys.getenv("API_KEY"))

if (file.exists("data/clinics_coords.Rda")) {
  load("data/clinics_coords.Rda")

} else {
  clinics_coords_ggmap <- clinics %>%
    mutate_geocode(address)

  save(clinics_coords_ggmap, file = "data/clinics_coords.Rda")

}

# PLOT ----------------------------------------------------------------------------------------
# A quick check of the data

leaflet(data = clinics_coords_ggmap) %>%
  addTiles() %>%
  addMarkers(~lon, ~lat,
             popup = ~paste0("<b>", as.character(title), "</b>", "<br>", as.character(address)),
             label = ~as.character(title))

