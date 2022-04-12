library(tidycensus)
library(ggplot2)
library(tidyverse)
library(dplyr)
library(rgdal)
library(sf)
library(raster)

root.dir = "https://raw.githubusercontent.com/urbanSpatial/Public-Policy-Analytics-Landing/master/DATA/"
source("https://raw.githubusercontent.com/urbanSpatial/Public-Policy-Analytics-Landing/master/functions.r")

census_api_key("3050a770b2aedfa128dd2ccc6ca8b8524fccc775", overwrite = TRUE)
palette5 <- c("#25CB10", "#5AB60C", "#8FA108",   "#C48C04", "#FA7800")


station_final <- st_read("C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/final_mat/stations_access_jobs_census.shp")
Study.sf <- st_read("C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/Tract_map_TOD_0208.shp")
DVRPC_TOD <- st_read("C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/raw_data/DVRPC_TOD/TOD_Opportunities.shp")

locality <- st_read("https://opendata.arcgis.com/datasets/0af75c94e931476ba0abec18f369875c_0.geojson")%>%
  st_transform(4326)%>%
  filter(dvrpc_reg == "Yes")

summary(as.numeric(station_loc$acres[station_loc$mun_type =="Borough"]))
summary(as.numeric(station_loc$acres[station_loc$mun_type =="Township"]))
summary(as.numeric(station_loc$acres[station_loc$mun_type =="City"]))

loc <- locality%>%
  dplyr::select(mun_type, acres, geometry)

station_loc <- st_join(station_final, loc, join = st_within, left= TRUE)%>%
  mutate(loc_sc = ifelse(mun_type == "City", 10,
                         ifelse(mun_type == "Borough", 8,
                                ntile(-acres, 7))))%>%
  dplyr::select(-mun_type, -acres)
  
station_l2 <- station_loc[, c("ID", "station", "line", "operator", "type_sym", "type", 
                "ac_score", "job_sc", "surp_sc", "em_surp_sc",
                "pvt_qn", "MdInm_qn", "not_gen", "loc_sc",
                "geometry")]

station_l2$ac_score[station_l2$ac_score < 5] <- 1 

st_write(station_l2, "C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/final_mat/stations_access_jobs_census_loc_0411.shp")

ggplot() +
  geom_sf(data=st_union(Study.sf)) +
  geom_sf(data=station_l2, aes(colour = not_gen),
          show.legend = "point", size = 5) +
  labs(title="DVRPC's analysis of Station area", 
       subtitle="Station by likelyhood of being gentrified", 
       caption="Figure xx") +
  mapTheme()
