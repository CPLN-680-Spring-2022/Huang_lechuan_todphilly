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
TODyes <- st_read("C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/TODtracts.shp")
DVRPC_TOD <- st_read("C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/raw_data/DVRPC_TOD/TOD_Opportunities.shp")
DVRPC_railstops <- st_read("C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/Transitstations.shp")

TOD_parcel2 <- st_read("C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/800buffer/TOD_800bufer_parcelpoint.shp")
TOD_station_parcel<- st_read("C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/800buffer/TODstation_bufferparcel_analysis.shp")
#B01001_001 Total Population B11016_001 Housholed
#B02001_002 White alone, B02001_003 Black, B02001_004 Native, B02001_005 Asian, B03001_003 Hispanic or Latinx
#B06011_001 Median Income, B05010_001 Poverty Rate, B07013_002 owner housing, B07013_003 renter housing
#B19119_001 Total HH, B19119_002 2-person hh, B19119_003 3-person hh, B19119_004 4-person hh, B19119_005 5-person hh, B19119_006 6-person hh, B19119_007 >7hh
#B25002_001 Total B25002_002 Occupied B25002_003 Vacant
#B25031_001 MedRent

DVRPC_railstops <- tibble::rowid_to_column(DVRPC_railstops, "ID")%>%
  st_transform(st_crs(Study.sf))

Buffers <- st_buffer(DVRPC_railstops, 800)

DVRPC_Parcel <- st_read("C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/raw_data/Greater_Philadelphia_2015_Land_Use.shp")%>%
  st_transform(st_crs(Study.sf))

#filter parcels within TOD buffers


#join parcels to buffers
TOD_parcel_buffer <- st_join(TOD_parcel2, Buffers)

TOD_parcel_buffer2 <- TOD_parcel_buffer%>%
  st_drop_geometry()%>%
  group_by(ID, lu15catn)%>%
  dplyr::summarise(count_parcel = n())

TOD_parcel_buffer3 <- TOD_parcel_buffer2 %>%
  as_tibble()

TOD_parcel_buffer4 <- spread(TOD_parcel_buffer3, key = lu15catn, value = count_parcel)

TOD_parcel_buffer5 <- TOD_parcel_buffer%>%
  st_drop_geometry()%>%
  group_by(ID, lu15catn)%>%
  dplyr::summarise(type_area = sum(Shape__Are))

TOD_parcel_buffer6 <- TOD_parcel_buffer5 %>%
  as_tibble()

TOD_parcel_buffer7 <- spread(TOD_parcel_buffer6, key = lu15catn, value = type_area)%>%
  dplyr::rename(ID.8 = ID, agr_area = Agriculture, Com_area = Commercial, Indu_area = Industrial,
                Ins_area = Institutional, Mil_area = Military, Recre_area = Recreation,
                Resi_area = Residential, Tran_area = Transportation, Under_area = Undeveloped,
                Util_area = Utility, Water_area = Water, Wood_area = Wooded)

#mixeduse
TOD_parcel_mixedtract <- TOD_parcel_buffer%>%
  st_drop_geometry()%>%
  group_by(ID, mixeduse)%>%
  dplyr::summarise(count_parcel = n())

TOD_parcel_mixedtract2 <- TOD_parcel_mixedtract %>%
  as_tibble()

TOD_parcel_mixedtract3 <- spread(TOD_parcel_mixedtract2, key = mixeduse, value = count_parcel)%>%
  dplyr::rename(ID.3 = ID)

TOD_parcel_mixedtract4 <- TOD_parcel_buffer%>%
  st_drop_geometry()%>%
  group_by(ID, mixeduse)%>%
  dplyr::summarise(type_area = sum(Shape__Are))

TOD_parcel_mixedtract5 <- TOD_parcel_mixedtract4 %>%
  as_tibble()

TOD_parcel_mixedtract6 <- spread(TOD_parcel_mixedtract5, key = mixeduse, value = type_area)%>%
  dplyr::rename(Mix_area = Y,
                nomx_area = N)

#merge
TOD_parcel_buffer8 <- cbind(TOD_parcel_buffer4, TOD_parcel_buffer7)%>%
  dplyr::select(-ID.8)

TOD_parcel_mixedtract8 <- cbind(TOD_parcel_mixedtract3, TOD_parcel_mixedtract6)%>%
  dplyr::select(-ID.3)%>%
  dplyr::rename(ID.7 = ID,
                MixedUse_yes = Y, MixedUse_no = N)

parcel_analysis <- cbind(TOD_parcel_buffer8, TOD_parcel_mixedtract8)%>%
  dplyr::select(-ID.7)

parcel_analysis[is.na(parcel_analysis)] = 0

parcel_analysis <- parcel_analysis%>%
  mutate(totalpc = MixedUse_yes + MixedUse_no)

parcel_analysis <- parcel_analysis%>%
  mutate(Mixedpct= (MixedUse_yes/totalpc)*100,
         Transpct = (Transportation/totalpc)*100,
         Commpct = (Commercial/totalpc)*100,
         Induspct = (Industrial/totalpc)*100,
         Civilpct = ((Institutional+Recreation+Utility)/totalpc)*100,
         Resipct = (Residential/totalpc)*100,
         underpct = ((Agriculture + Wooded + Undeveloped)/totalpc)*100,
         Mx_ar_pct = Mix_area/2010000,
         Tran_ar_pct = Tran_area/2010000,
         Com_area_pct = Com_area/2010000,
         Ind_ar_pct = Indu_area/2010000,
         Civ_ar_pct = (Ins_area+Recre_area+Util_area)/2010000,
         Res_ar_pct = Resi_area/2010000,
         under_ar_pct = (agr_area+Under_area+Wood_area)/2010000)

TOD_station_parcel <- merge(DVRPC_railstops, parcel_analysis)

st_write(TOD_station_parcel, "C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/800buffer/TODstation_bufferparcel_analysis.shp")

#play with it 
TOD_station_parcel <- TOD_station_parcel%>%
  mutate(CtRe = Commpct/Resipct)

#visualization
ggplot() +
  geom_sf(data=st_union(Study.sf)) +
  geom_sf(data=TOD_station_parcel, aes(colour = Mx_ar_pct),
          show.legend = "point", size = 5) +
  labs(title="DVRPC's analysis of Station area", 
       subtitle="DVRPC", 
       caption="Figure xx") +
  mapTheme()
