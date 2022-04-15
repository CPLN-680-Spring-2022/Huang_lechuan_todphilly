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

station_final2 <- st_read("C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/final_mat/stations_access_jobs_census_loc_slope_parcel_0414.shp")
Study.sf <- st_read("C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/Tract_map_TOD_0208.shp")

station_final2[is.na(station_final2)] = 0

sapply(station_final2, is.numeric)

test <- station_parcel_out%>%
  mutate(sc_aph = ac_score*0.09 + job_sc*0.13 + em_surp_sc*0.18 +
                      pvt_qn*0.07 + MdInm_qn*0.04 +  not_gen*0.05 +
                      loc_sc*0.05 + slo_sc*0.05 +
                      duti_sc*0.31 + attr_sc*0.25 + unattr_sc*0.10)%>% 
  arrange(desc(sc_aph))

TODParcels <- st_read("C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/TOD_parcels_point.shp")

test <- test[, c("ID", "station", "line", "operator", "type_sym", "type", 
                 "ac_score", "job_sc", "em_surp_sc",
                 "pvt_qn", "MdInm_qn", "not_gen", "loc_sc", "slo_sc",
                 "duti_sc", "attr_sc", "unattr_sc", "sc_aph",
                 "geometry")]

st_write(test, "C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/final_mat/TOD_stationlist_0414.shp")

#siting categorization
TODParcels <- st_read("C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/TOD_parcels_point.shp")

summary(as.factor(TODParcels$lu15catn))

summary(as.factor(TODParcels$lu15subn))

TODParcels$Shape__Are

Redev2 <- filter(TODParcels, lu15catn == c("Agriculture", "Industrial"))
Redev3 <- filter(TODParcels, lu15subn == c("Undeveloped: General", "Undeveloped: Transitional Land",
                           "Parking - Transportation: Facility",  "Parking - Undeveloped: Undetermined Use"))

Redev1 <- rbind(Redev2, Redev3)

Redev <- filter(Redev1, Shape__Are > 4000)%>%
  dplyr::select(lu15catn, lu15subn, mun_name, Shape__Are, geometry)%>%
  st_transform(4326)

summary(as.factor(Redev$lu15subn))

ggplot() +
  geom_sf(data=st_union(Study.sf)) +
  geom_sf(data=Redev, aes(colour = lu15catn),
          show.legend = "point", size = 3) +
  labs(title="DVRPC's analysis of Station area", 
       subtitle="Existing large parcels around the station", 
       caption="Figure xx") +
  mapTheme()

station_buffer <- st_buffer(test, 500)%>%
  st_transform(4326)

available_parcel <- st_join(Redev, station_buffer)%>%
  dplyr::select(-"line", -"operator", -"type_sym", -"type", 
                -"ac_score", -"job_sc", -"em_surp_sc",
                -"pvt_qn", -"MdInm_qn", -"not_gen", -"loc_sc", -"slo_sc",
                -"duti_sc", -"attr_sc", -"unattr_sc", -"sc_aph")

parcels_ana <- available_parcel%>%
  st_drop_geometry()%>%
  group_by(ID)%>%
  na.omit()%>%
  dplyr::summarise(under_n = sum(lu15subn == "Undeveloped: General" |lu15subn ==  "Undeveloped: Transitional Land"),
                   park_n = sum(lu15subn == "Parking - Transportation: Facility" |lu15subn ==  "Parking - Undeveloped: Undetermined Use"),
                   ind_n = sum(lu15catn == "Industrial"),
                   ag_n = sum(lu15subn == "Agriculture"),
                   under_ar = sum(Shape__Are[lu15subn == "Undeveloped: General" |lu15subn ==  "Undeveloped: Transitional Land"]),
                   park_ar = sum(Shape__Are[lu15subn == "Parking - Transportation: Facility" |lu15subn ==  "Parking - Undeveloped: Undetermined Use"]),
                   ind_ar = sum(Shape__Are[lu15catn == "Industrial"]),
                   ag_ar = sum(Shape__Are[lu15subn == "Agriculture"])
                   )

station_vacant <- merge(test, parcels_ana, by = "ID", all = TRUE)%>%
  dplyr::select(-"operator", -"type_sym", -"type", 
                -"ac_score", -"job_sc", -"em_surp_sc",
                -"pvt_qn", -"MdInm_qn", -"not_gen", -"loc_sc", -"slo_sc",
                -"duti_sc", -"attr_sc", -"unattr_sc")

station_vacant[is.na(station_vacant)] = 0

st_write(station_vacant, "C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/final_mat/station_largeTOD_500m.shp")

#difference
TOD500 <- station_vacant%>%
  mutate(parce500 = under_n + park_n + ind_n + ag_n,
         are500 = under_ar + park_ar + ind_ar + ag_ar)%>%
  dplyr::select(-under_n, -park_n, -ind_n, -ag_n)

TOD800 <- st_read("C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/final_mat/station_large_TOD.shp")%>%
  mutate(parce800 = under_n + park_n + ind_n + ag_n,
         are800 = under_ar + park_ar + ind_ar + ag_ar)%>%
  dplyr::select(-station, -sc_aph, -under_n, -park_n, -ind_n, -ag_n, -geometry)%>%
  st_drop_geometry()


distance_dif <- merge(TOD800, TOD500, by = "ID", all = TRUE)

distance_dif <- distance_dif[, c("ID", "station", "line", "sc_aph",
                                 "parce800", "parce500", "are800", "are500",
                                 "geometry")]

st_write(distance_dif, "C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/final_mat/largeTOD_dif.shp")

#DVRPC Comparison
DVRPC_TOD <- st_read("C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/raw_data/DVRPC_TOD/TOD_Opportunities.shp")%>%
  st_transform(4326)%>%
  dplyr::select(STATION, LINE, ExistingOr, FuturePote)

test_clean <- test%>%
  dplyr::select(-"operator", -"type_sym", -"type", 
                -"ac_score", -"job_sc", -"em_surp_sc",
                -"pvt_qn", -"MdInm_qn", -"not_gen", -"loc_sc", -"slo_sc",
                -"duti_sc", -"attr_sc", -"unattr_sc")
  

rate_dif <- st_join(DVRPC_TOD, test_clean, join = st_nearest_feature)

rate_dif <- rate_dif%>%
  mutate(aph_b2 = sc_aph/2,
         diff = aph_b2 - FuturePote,
         diff_ep = ifelse(ExistingOr > FuturePote, aph_b2 - ExistingOr,
         aph_b2 - FuturePote))

rate_diff <- rate_dif[, c("ID", "station", "line", "ExistingOr", "FuturePote", 
                          "aph_b2", "diff", "diff_ep",
                          "geometry")]

st_write(rate_diff, "C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/final_mat/Predict_DVRPC_diff.shp")

diff <- st_read("C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/final_mat/Predict_DVRPC_diff.shp")

ggplot() +
  geom_sf(data=st_union(Study.sf)) +
  geom_sf(data=rate_diff, aes(colour = diff_ep),
          show.legend = "point", size = 3) +
  labs(title="Prediction Difference", 
       subtitle="My Prediction - DVRPC's Prediction", 
       caption="Figure xx") +
  mapTheme()
