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

station_final2 <- st_read("C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/final_mat/stations_final_0421.shp")
Study.sf <- st_read("C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/Tract_map_TOD_0208.shp")


test <- station_final2%>%
  mutate(sc_aph = ac_score*0.1 + job_sc*0.1 + em_surp_sc*0.13 +
           pvt_qn*0.07 + MdInm_qn*0.04 +  not_gen*0.09 +
           loc_sc*0.08 + slo_sc*0.04 +
           duti_sc*0.1 + attr_sc*0.14 + unattr_sc*0.1)%>% 
  arrange(desc(sc_aph))

test.grade <- test%>%
  mutate(grade = ifelse(sc_aph > 7, "Larger than 7 (Ideal)", 
                        ifelse(sc_aph < 7.01 & sc_aph > 4.99, "Between 5 and 7 (Mediocre)",
                               ifelse(sc_aph < 5, "Lower than 5 (Not ideal)", 0))))

test.grade <- test.grade[, c("ID", "station", "line", "operator", "type_sym", "type", 
                             "ac_score", "job_sc", "em_surp_sc",
                             "pvt_qn", "MdInm_qn", "not_gen", "loc_sc", "slo_sc",
                             "duti_sc", "attr_sc", "unattr_sc", "sc_aph", "grade",
                             "state_name", "co_name", "mun_name", "mun_type",
                             "geometry")]

TODParcels <- st_write(test, "C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/final_mat/stations_final_0425.shp")

geojson_write(test.grade, 
              file = "C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/webframe/stations_final_0426.geojson")
