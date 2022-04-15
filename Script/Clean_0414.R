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

station_final <- st_read("C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/final_mat/stations_access_jobs_census_loc_slope_0412.shp")
Study.sf <- st_read("C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/Tract_map_TOD_0208.shp")

DVRPC_TOD <- st_read("C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/raw_data/DVRPC_TOD/TOD_Opportunities.shp")

station_parcel <- st_read("C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/800buffer/Final_parcel_analysis_area.shp")

#aggregate by hand
#Trenton
station_parcel$ID[station_parcel$ID %in% c("31", "35", "40")] <- 31 
#North Philadelphia
station_parcel$ID[station_parcel$ID %in% c("108", "188", "287")] <- 277
#Camden (RIVERLINE + PATCO)
station_parcel$ID[station_parcel$ID %in% c("49", "156")] <- 49
#Lindenwold
station_parcel$ID[station_parcel$ID %in% c("165", "210")] <- 165
#Pennsauken
station_parcel$ID[station_parcel$ID %in% c("186", "253")] <- 253
#Fern Rock
station_parcel$ID[station_parcel$ID %in% c("116", "307")] <- 307
#69th St
station_parcel$ID[station_parcel$ID %in% c("4", "201", "282")] <- 4
#8th St
station_parcel$ID[station_parcel$ID %in% c("231", "237", "296")] <- 296
#Center City (15, City Hall, Suburban)
station_parcel$ID[station_parcel$ID %in% c("297", "260", "314")] <- 314
#Norristown
station_parcel$ID[station_parcel$ID %in% c("144", "284")] <- 144
#Jefferson 11th
station_parcel$ID[station_parcel$ID %in% c("48", "221")] <- 221


#agr_area = Agriculture, Com_area = Commercial, Indu_area = Industrial,
#Ins_area = Institutional, Mil_area = Military, Recre_area = Recreation,
#Resi_area = Residential, Tran_area = Transportation, Under_area = Undeveloped,
#Util_area = Utility, Water_area = Water, Wood_area = Wooded

#com_lgret_ar = "Commercial: Single Large-Site Retail", com_mx_ar = "Commercial: Mixed-Use", 
#edu_ar = "Institutional: Education", 
#pkin_tran_ar = "Parking - Transportation: Facility", pkin_und_ar = "Parking - Undeveloped: Undetermined Use", 
#resi_mx_ar = "Residential: Mixed-Use", resi_multi_ar = "Residential: Multifamily", resi_sigle_ar = "Residential: Single-Family Detached",
#under_gen_ar = "Undeveloped: General", under_trsit_ar = "Undeveloped: Transitional Land"

station_parcel$cm_mx_r

parcel_ann3 <- station_parcel%>%
  mutate(under = (agr_are + undr_g_ + Under_r + pkn_tr_ + pkn_nd_),
         attr = (Ins_are + Com_are + Recre_r),
         unattr = (Indu_ar + Mil_are + Util_ar))%>%
  dplyr::select(-"station", -"line", -"operatr", -"typ_sym", -"type")%>%
  st_drop_geometry()

station_parcel_join <- merge(station_final, parcel_ann3, by="ID")


station_parcel_join <- station_parcel_join%>%
  mutate(duti_sc = as.numeric(cut(station_parcel_join$under, 10)),
         attr_sc = as.numeric(cut(station_parcel_join$attr, 10)),
         unattr_sc = as.numeric(cut(-station_parcel_join$unattr, 10))
  )

station_parcel_out <- station_parcel_join[, c("ID", "station", "line", "operator", "type_sym", "type", 
                                              "ac_score", "job_sc", "em_surp_sc",
                                              "pvt_qn", "MdInm_qn", "not_gen", "loc_sc", "slo_sc",
                                              "duti_sc", "attr_sc", "unattr_sc",
                                              "geometry")]

st_write(station_parcel_out, "C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/final_mat/stations_access_jobs_census_loc_slope_parcel_0414.shp")

#detailed data

station_parcel_at<- station_parcel_join[, c("ID", "station", "line", "operator", "type_sym", "type",
                      "agr_are", "undr_g_", "Under_r", "Wood_ar", "pkn_tr_", "pkn_nd_", 
                      "Ins_are", "Com_are", "Recre_r", "Indu_ar", "Mil_are", "Util_ar", 
                      "under", "duti_sc", "attr", "attr_sc", "unattr", "unattr_sc",
                      "geometry")]

st_write(station_parcel_at, "C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/final_mat/stations_parcel_0414.shp")

#for later
parcel_proportion <- station_parcel%>%
  mutate(com.hdre = Com_are/(Resi_ar + Ins_are))%>%
  dplyr::select("ID", "station", "line",
                com.hdre,
                geometry)

#visualization
ggplot() +
  geom_sf(data=st_union(Study.sf)) +
  geom_sf(data=station_parcel_join, aes(colour = unattr),
          show.legend = "point", size = 5) +
  labs(title="DVRPC's analysis of Station area", 
       subtitle="Station with the most attractive amenities (Industry, Military, Utility)", 
       caption="Figure xx") +
  mapTheme()



