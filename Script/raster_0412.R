library(tidycensus)
library(ggplot2)
library(tidyverse)
library(dplyr)
library(rgdal)
library(sf)
library(raster)

slopep <- st_read("C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/raw_data/DEM/slo_select.shp")

final <- st_read("C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/final_mat/stations_access_jobs_census_loc_0412.shp")

station_sl <- st_join(final, slopep, join = st_nearest_feature, left= TRUE)%>%
  dplyr::select(-pointid)%>%
  rename(slope = grid_code)

#clean center city
station_sl$slope[station_sl$ID %in% c("314", "219", "200", "175", "37", "221")] <- 0

station_sl <- station_sl%>%
  mutate(slo_sc = as.numeric(cut(-station_sl$slope, 10)))

station_slp <- station_sl%>%
  dplyr::select("ID", "station", "line", "operator", "type_sym", "type", slope, slo_sc, geometry)

station_sl2 <- station_sl[, c("ID", "station", "line", "operator", "type_sym", "type", 
                              "ac_score", "job_sc", "surp_sc", "em_surp_sc",
                              "pvt_qn", "MdInm_qn", "not_gen", "loc_sc", "slo_sc",
                              "geometry")]

st_write(station_sl2, "C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/final_mat/stations_access_jobs_census_loc_slope_0412.shp")

st_write(station_slp, "C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/final_mat/stations_slope.shp")

ggplot() +
  geom_sf(data=st_union(Study.sf)) +
  geom_sf(data=station_sl2, aes(colour = slo_sc),
          show.legend = "point", size = 5) +
  labs(title="DVRPC's analysis of Station area", 
       subtitle="Station by slope", 
       caption="Figure xx") +
  mapTheme()
