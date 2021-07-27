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
# Walking distance of 10 minutes
?osrmIsochrone
clinics_coords <- clinics_coords_ggmap %>%
  # slice(1:5) %>%
  identity()

isochrones_all <- osrmIsochrone(loc = c(clinics_coords$lon[1], clinics_coords$lat[1]),
                                breaks = seq(from = 0, to = 10, by = 10),
                                res = 20)

for (i in 2:nrow(clinics_coords)) {

  iso_data <- osrmIsochrone(loc = c(clinics_coords$lon[i], clinics_coords$lat[i]),
                            breaks = seq(from = 0, to = 10, by = 10),
                            res = 20)

  isochrones_all <- rbind(isochrones_all, iso_data)
}


# MAP WITH LEAFLET ----------------------------------------------------------------------------

leaflet(data = isochrones_all) %>%
  # setView(lng = 1.428678, lat = 43.598139, zoom = 13) %>%
  addTiles() %>%
  # addMarkers(lng = 1.428678, lat = 43.598139, popup = "My Airbnb") %>%
  addPolygons(fillOpacity=0.3, color = "purple",
              weight = 1,
              opacity = 1.0,
              highlightOptions = highlightOptions(color = "white", weight = 2,
                                                   bringToFront = TRUE))
