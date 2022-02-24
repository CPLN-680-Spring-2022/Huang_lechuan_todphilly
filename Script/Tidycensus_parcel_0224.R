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


TODyes <- st_read("C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/TODtracts.shp")
TODParcels <- st_read("C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/TOD_parcels_point.shp")

#study existing TOD tracts condition
TOD_parcel_tract <- st_join(TODParcels, TODyes)


TOD_parcel_tract2 <- TOD_parcel_tract%>%
  group_by(NAME, lu15dev)%>%
  summarise(count_parcel = n())

TOD_parcel_tract3 <- TOD_parcel_tract2 %>%
  as_tibble()%>%
  dplyr::select(-geometry)

TOD_parcel_tract4 <- spread(TOD_parcel_tract3, key = lu15dev, value = count_parcel)


TOD_parcel_mixedtract <- TOD_parcel_tract%>%
  group_by(NAME, mixeduse)%>%
  summarise(count_parcel = n())

TOD_parcel_mixedtract2 <- TOD_parcel_mixedtract %>%
  as_tibble()%>%
  dplyr::select(-geometry)

TOD_parcel_mixedtract3 <- spread(TOD_parcel_mixedtract2, key = mixeduse, value = count_parcel)%>%
  dplyr::rename(MixedUse_yes = Y,
                MixedUse_no = N,
                name.y = NAME)

parcel_analysis <- cbind(TOD_parcel_tract4, TOD_parcel_mixedtract3)%>%
  dplyr::select(-name.y)

parcel_analysis[is.na(parcel_analysis)] = 0

parcel_analysis <- parcel_analysis%>%
  mutate(totalpc = MixedUse_yes + MixedUse_no)%>%
  dplyr::rename(Other = "Other Developed",
                Trans = "Transportation and Parking",
                Wooded = "Wooded or Undeveloped")

parcel_analysis <- parcel_analysis%>%
  mutate(Mixedpct= (MixedUse_yes/totalpc)*100,
         Transpct = (Trans/totalpc)*100,
         Resipct = (Residential/totalpc)*100,
         underpct = ((Agriculture + Wooded)/totalpc)*100)

TOD_tract_parcel <- merge(TODyes, parcel_analysis)

st_write(TOD_tract_parcel, "C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/TODtract_with_parcel_ana.shp")

TOD_tract_parcel <- st_read("C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/TODtract_with_parcel_ana.shp")
Study.sf <- st_read("C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/Tract_map_TOD_0208.shp")
Water <- st_read("C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/raw_data/Water_1500.shp")



ggplot()+
  geom_sf(data = st_union(Study.sf))+
  geom_sf(data=TOD_tract_parcel,
          aes(fill = q5(undrpct))) +
  scale_fill_manual(values = c("#f0f9e8","#bae4bc","#7bccc4","#43a2ca","#0868ac"),
                    labels = qBr(TOD_tract_parcel, "undrpct"),
                    name = "undrpct \n(Quintile Breaks)") +
  labs(title = "Underused parcels proportions among TOD tracts", subtitle = "E.g.: Agriculture, Forest, undeveloped") +
  mapTheme() + 
  theme(plot.title = element_text(size=22))
