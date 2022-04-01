library(tidycensus)
library(ggplot2)
library(tidyverse)
library(dplyr)
library(rgdal)
library(sf)
library(tigris)

root.dir = "https://raw.githubusercontent.com/urbanSpatial/Public-Policy-Analytics-Landing/master/DATA/"
source("https://raw.githubusercontent.com/urbanSpatial/Public-Policy-Analytics-Landing/master/functions.r")

census_api_key("3050a770b2aedfa128dd2ccc6ca8b8524fccc775", overwrite = TRUE)
palette5 <- c("#25CB10", "#5AB60C", "#8FA108",   "#C48C04", "#FA7800")


Study.sf <- st_read("C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/Tract_map_TOD_0208.shp")
TODTracts <- st_read("C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/TODtracts.shp")
DVRPC_railstops <- st_read("C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/Transitstations.shp")

TOD_parcel2 <- st_read("C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/800buffer/TOD_800bufer_parcelpoint.shp")
TOD_station_parcel<- st_read("C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/800buffer/TODstation_bufferparcel_analysis.shp")


#join parcels to buffers
TOD_parcel_buffer <- st_join(TOD_parcel2, Buffers)

TOD_parcel_buffer5 <- TOD_parcel_buffer%>%
  st_drop_geometry()%>%
  group_by(ID, lu15catn)%>%
  dplyr::summarise(type_area = sum(Shape__Are))

TOD_parcel_buffer6 <- TOD_parcel_buffer5 %>%
  as_tibble()

TOD_parcel_buffer7 <- spread(TOD_parcel_buffer6, key = lu15catn, value = type_area)%>%
  dplyr::rename(agr_area = Agriculture, Com_area = Commercial, Indu_area = Industrial,
                Ins_area = Institutional, Mil_area = Military, Recre_area = Recreation,
                Resi_area = Residential, Tran_area = Transportation, Under_area = Undeveloped,
                Util_area = Utility, Water_area = Water, Wood_area = Wooded)

#mixeduse
TOD_parcel_mixedtract4 <- TOD_parcel_buffer%>%
  st_drop_geometry()%>%
  group_by(ID, mixeduse)%>%
  dplyr::summarise(type_area = sum(Shape__Are))

TOD_parcel_mixedtract5 <- TOD_parcel_mixedtract4 %>%
  as_tibble()

TOD_parcel_mixedtract6 <- spread(TOD_parcel_mixedtract5, key = mixeduse, value = type_area)%>%
  dplyr::rename(ID.8 = ID, Mix_area = Y,
                nomx_area = N)

#important parcels
TOD_parcel_buffer11 <- TOD_parcel_buffer%>%
  st_drop_geometry()%>%
  group_by(ID, lu15subn)%>%
  dplyr::summarise(type_area = sum(Shape__Are))

TOD_parcel_buffer12 <- TOD_parcel_buffer11 %>%
  as_tibble()

TOD_parcel_buffer13 <- spread(TOD_parcel_buffer12, key = lu15subn, value = type_area)

Important_area <- TOD_parcel_buffer13%>%
  dplyr::select(com_lgret_ar = "Commercial: Single Large-Site Retail", com_mx_ar = "Commercial: Mixed-Use", edu_ar = "Institutional: Education", 
                pkin_tran_ar = "Parking - Transportation: Facility", pkin_und_ar = "Parking - Undeveloped: Undetermined Use", 
                resi_mx_ar = "Residential: Mixed-Use", resi_multi_ar = "Residential: Multifamily", resi_sigle_ar = "Residential: Single-Family Detached",
                under_gen_ar = "Undeveloped: General", under_trsit_ar = "Undeveloped: Transitional Land")


#merge
TOD_parcel_mixedtract8 <- cbind(TOD_parcel_buffer7, TOD_parcel_mixedtract6)%>%
  dplyr::select(-ID.8)

Final_parcel_almost <- cbind(TOD_parcel_mixedtract8, Important_area)%>%
  dplyr::rename(ID.f = ID)

Final_parcel <- cbind(DVRPC_railstops, Final_parcel_almost)%>%
  dplyr::select(-ID.f)

Final_parcel[is.na(Final_parcel)] = 0

st_write(Final_parcel, "C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/800buffer/Final_parcel_analysis_area.shp")

write.csv(Final_parcel, "C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/800buffer/Final_parcel_analysis_cleaning.csv")
#play with it 
TOD_station_parcel <- TOD_station_parcel%>%
  mutate(CtRe = Commpct/Resipct)

#visualization
ggplot() +
  geom_sf(data=st_union(Study.sf)) +
  geom_sf(data=TOD_station_parcel, aes(colour = presi),
          show.legend = "point", size = 5) +
  labs(title="DVRPC's analysis of Station area", 
       subtitle="Average Residential Parcel size", 
       caption="Figure xx") +
  mapTheme()

#tweak DVRPC
DVRPC_TOD <- st_read("C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/raw_data/DVRPC_TOD/TOD_Opportunities.shp")

#extract useful predictors
DVRPC_TOD <- DVRPC_TOD%>%
  st_drop_geometry()%>%
  dplyr::select(STATION, LINE, Type_1, TCI_Data, Job_Data, Time_Data, Walk_data,
                ResRent_Da, CommRent_D)

write.csv(DVRPC_TOD, "C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/800buffer/DVRPC_cleaning.csv")
