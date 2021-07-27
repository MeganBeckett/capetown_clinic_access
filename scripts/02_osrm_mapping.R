###############################################################################################
#
# Mapping walking accessibility with OSRM
#
# Megan Beckett
#
###############################################################################################

# LIBRARIES -----------------------------------------------------------------------------------
library(dplyr)
library(tidyr)
library(leaflet)
library(osrm)

# OSRM SERVER ---------------------------------------------------------------------------------
# I have a server running locally.
options(osrm.server = "http://127.0.0.1:5000/")
options(osrm.profile = "foot")
getOption("osrm.profile")
# DATA ----------------------------------------------------------------------------------------
load("data/clinics_coords.Rda")


# GENERATE ISOCHRONES -------------------------------------------------------------------------
?osrmIsochrone

# Slice dataframe if needed for testing
clinics_coords <- clinics_coords_ggmap %>%
  # slice(1:5) %>%
  identity()

# Function to generate isochrones

generate_iso <- function(df, walking_min = 10, res = 20) {

  # Generate first isochrone
  isochrones_all <- osrmIsochrone(loc = c(df$lon[1], df$lat[1]),
                                  breaks = seq(from = 0, to = walking_min, by = walking_min),
                                  res = res)

  # Loop through the rest and bind together
  for (i in 2:nrow(df)) {

    isochrone <- osrmIsochrone(loc = c(df$lon[i], df$lat[i]),
                              breaks = seq(from = 0, to = walking_min, by = walking_min),
                              res = res)

    isochrones_all <- rbind(isochrones_all, isochrone)
  }

  isochrones_all
}

# Generate isochrone data at 10, 30 and 60 min walking time intervals
isochrones_10 <- generate_iso(clinics_coords)

isochrones_20 <- generate_iso(clinics_coords, walking_min = 20)

isochrones_30 <- generate_iso(clinics_coords, walking_min = 30)

isochrones_60 <- generate_iso(clinics_coords, walking_min = 60)


# MAP WITH LEAFLET ----------------------------------------------------------------------------
m <- leaflet() %>%
  addTiles() %>%
  addPolygons(data = isochrones_20,
              fillOpacity=0.3, color = "purple",
              weight = 1,
              opacity = 1.0,
              highlightOptions = highlightOptions(color = "white", weight = 2,
                                                  bringToFront = TRUE))
m

m %>%
  addMarkers(data = clinics_coords, ~lon, ~lat,
             popup = ~paste0("<b>", as.character(title), "</b>", "<br>", as.character(address)),
             label = ~as.character(title))
