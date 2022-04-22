library(tidycensus)
library(ggplot2)
library(tidyverse)
library(dplyr)
library(rgdal)
library(sf)
library(raster)
library(geojsonsf)
library(geojsonio)

root.dir = "https://raw.githubusercontent.com/urbanSpatial/Public-Policy-Analytics-Landing/master/DATA/"
source("https://raw.githubusercontent.com/urbanSpatial/Public-Policy-Analytics-Landing/master/functions.r")

census_api_key("3050a770b2aedfa128dd2ccc6ca8b8524fccc775", overwrite = TRUE)
palette5 <- c("#25CB10", "#5AB60C", "#8FA108",   "#C48C04", "#FA7800")

county <- st_read("https://arcgis.dvrpc.org/portal/rest/services/Boundaries/CountyBoundaries/FeatureServer/0/query?outFields=*&where=1%3D1&f=geojson")%>%
  filter(., dvrpc_reg == "Yes")%>%
  st_transform(4326)

tod_ranking <- st_read("C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/final_mat/TOD_stationlist_0414.shp")


#visualization
ggplot() +
  geom_sf(data=county) +
  geom_sf(data=tod_ranking, aes(colour = sc_aph),
          show.legend = "point", size = 5) +
  labs(title="DVRPC's analysis of Station area", 
       subtitle="TOD Index", 
       caption="Figure xx") +
  mapTheme()

#jsfile
locality <- st_read("https://opendata.arcgis.com/datasets/0af75c94e931476ba0abec18f369875c_0.geojson")%>%
  st_transform(4326)%>%
  filter(dvrpc_reg == "Yes")

loca <- locality%>%
  dplyr::select(state_name, co_name, mun_name, mun_type, geometry)%>%
  filter(., co_name != "Philadelphia")

phila <- st_read("C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/raw_data/Neihorhoods/Neighborhoods_Philadelphia.shp")

phila <- phila%>%
  mutate(state_name = "Pennsylvania",
         co_name = "Philadelphia",
         mun_type = "Philadelphia Neighborhoods")%>%
  rename(mun_name = LISTNAME)%>%
  dplyr::select(state_name, co_name, mun_name, mun_type, geometry)%>%
  st_transform(4326)
    
location <- rbind(loca, phila)
  
station_js  <- st_join(tod_ranking, location, join = st_within, left= TRUE)

station_js_sf <- sf_geojson(station_js)
  

class(station_js_sf)

st_write(station_js, "C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/final_mat/stations_final_0421.shp")

geojson_write(station_js, 
              file = "C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/final_mat/station_final_0421_2.geojson")

#
tod_parcels <- st_read("C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/final_mat/station_largeTOD_500m.shp")

geojson_write(tod_parcels, 
              file = "C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/final_mat/station_largeTOD_500m.geojson")
