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

sf_use_s2(FALSE)

DVRPC_Parcel <- DVRPC_Parcel%>%
  s2_rebuild()

#filter parcels within TOD buffers
TOD_parcel2 <- st_filter(st_centroid(DVRPC_Parcel), Buffers, join = st_within)%>%
  st_sf()

st_write(TOD_parcel2, "C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/800buffer/TOD_800bufer_parcelpoint.shp")

ggplot() +
  geom_sf(data=st_union(Study.sf)) +
  geom_sf(data=TOD_parcel2, aes(fill = lu15catn)) +
  scale_fill_manual(values = c("#E3E4DB","#9e0142","#d53e4f","#f46d43","#fdae61","#fee08b",
                               "#e6f598","#abdda4","#66c2a5","#3288bd","#5e4fa2","#B8CC1A"))+
  labs(caption = "Figure xx") +
  mapTheme()

#join parcels to buffers
TOD_parcel_buffer <- st_join(TOD_parcel2, Buffers)

TOD_parcel_buffer2 <- TOD_parcel_buffer%>%
  st_drop_geometry()%>%
  group_by(ID, lu15catn)%>%
  dplyr::summarise(count_parcel = n())

TOD_parcel_buffer3 <- TOD_parcel_buffer2 %>%
  as_tibble()

TOD_parcel_buffer4 <- spread(TOD_parcel_buffer3, key = lu15catn, value = count_parcel)

#mixeduse
TOD_parcel_mixedtract <- TOD_parcel_buffer%>%
  st_drop_geometry()%>%
  group_by(ID, mixeduse)%>%
  dplyr::summarise(count_parcel = n())

TOD_parcel_mixedtract2 <- TOD_parcel_mixedtract %>%
  as_tibble()

TOD_parcel_mixedtract3 <- spread(TOD_parcel_mixedtract2, key = mixeduse, value = count_parcel)%>%
  dplyr::rename(ID.y = ID)

#merge
parcel_analysis <- cbind(TOD_parcel_buffer4, TOD_parcel_mixedtract3)%>%
  dplyr::select(-ID.y)%>%
  dplyr::rename(MixedUse_yes = Y,
         MixedUse_no = N)

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
         underpct = ((Agriculture + Wooded)/totalpc)*100)

TOD_station_parcel <- merge(DVRPC_railstops, parcel_analysis)

st_write(TOD_station_parcel, "C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/800buffer/TODstation_bufferparcel_analysis.shp")

#play with it 
TOD_station_parcel <- TOD_station_parcel%>%
  mutate(CtRe = Commpct/Resipct)

#visualization
ggplot() +
  geom_sf(data=st_union(Study.sf)) +
  geom_sf(data=DVRPC_TOD, aes(colour = Type_1),
          show.legend = "point", size = 5) +
  labs(title="DVRPC's analysis of Station area", 
       subtitle="DVRPC", 
       caption="Figure xx") +
  mapTheme()
