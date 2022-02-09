library(tidycensus)
library(ggplot2)
library(tidyverse)
library(dplyr)
library(rgdal)
library(sf)

root.dir = "https://raw.githubusercontent.com/urbanSpatial/Public-Policy-Analytics-Landing/master/DATA/"
source("https://raw.githubusercontent.com/urbanSpatial/Public-Policy-Analytics-Landing/master/functions.r")

census_api_key("3050a770b2aedfa128dd2ccc6ca8b8524fccc775", overwrite = TRUE)

palette5 <- c("#25CB10", "#5AB60C", "#8FA108",   "#C48C04", "#FA7800")

#B01001_001 Total Population B11016_001 Household
#B02001_002 White alone, B02001_003 Black, B02001_004 Native, B02001_005 Asian, B03001_003 Hispanic or Latinx
#B06011_001 Median Income, B05010_001 Poverty Rate, B07013_002 owner housing, B07013_003 renter housing
#B19119_001 Total HH, B19119_002 2-person hh, B19119_003 3-person hh, B19119_004 4-person hh, B19119_005 5-person hh, B19119_006 6-person hh, B19119_007 >7hh
#B25002_001 Total B25002_002 Occupied B25002_003 Vacant


Study.sf <- st_read("C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/Tract_map_0203.shp")
DVRPC_TOD <- st_read("C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/raw_data/DVRPC_TOD/TOD_Opportunities.shp")
DVRPC_railstops <- st_read("C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/Transitstations.shp")


#BSL, MFL, NHSL, ATLANTIC, NEC, RIVERLINE, PATCO, SEPTA, Trolley
ggplot() + 
  geom_sf(data=Study.sf) +
  geom_sf(data=DVRPC_railstops, 
          aes(colour = type_sym), 
          show.legend = "point", size= 2) +
  scale_colour_manual(values = c("#ff8f1c", "#007dc3", "#781d7e", "#005DAA", "#EF3E42","#00A5E3", "#EF3E42", "#0255a1","#5d9731")) +
  labs(title="Rail Stops in DVRPC", 
       subtitle="Philadelphia, PA", 
       caption="Figure xx") +
  mapTheme()

#Buffer
Buffers <- 
  rbind(st_buffer(DVRPC_railstops, 800) %>%
      mutate(Legend = "Buffer") %>%
      dplyr::select(Legend),
    st_union(st_buffer(DVRPC_railstops, 800)) %>%
      st_sf() %>%
      mutate(Legend = "Unioned Buffer"))

ggplot() +
  geom_sf(data=st_union(Study.sf)) +
  geom_sf(data=Buffers) +
  geom_sf(data=DVRPC_railstops, show.legend = "point") +
  facet_wrap(~Legend) + 
  labs(caption = "Figure xx") +
  mapTheme()

unionbuffer <- filter(Buffers, Legend=="Unioned Buffer")

#Join study.sf to TOD Buffer


#blockgroups with the most vacant lots

Vacantlots <- filter(Study.sf, TotalPp > 500)%>%
  dplyr::select(GEOID, NAME, TotalPp, Totallt, Vcnt_lt)%>%
  mutate(pct_vacant = (Vcnt_lt/Totallt) * 100)

ggplot(Vacantlots)+
  geom_sf(data = st_union(Vacantlots))+
  geom_sf(aes(fill = q5(pct_vacant))) +
  geom_sf(data = unionbuffer, fill = "transparent", color = "red")+
  scale_fill_manual(values = c("#f0f9e8","#bae4bc","#7bccc4","#43a2ca","#0868ac"),
                    labels = qBr(Vacantlots, "pct_vacant"),
                    name = "pct_vacant\n(Quintile Breaks)") +
  labs(title = "Percentage of Vacant lot", subtitle = "DVRPC") +
  mapTheme() + 
  theme(plot.title = element_text(size=22))

sf_use_s2(FALSE)
TODtracts <- rbind(
    st_centroid(Study.sf)[unionbuffer,] %>%
      st_drop_geometry() %>%
      left_join(Study.sf) %>%
      st_sf() %>%
      mutate(TOD = "TOD"),
    st_centroid(Study.sf)[unionbuffer, op = st_disjoint] %>%
      st_drop_geometry() %>%
      left_join(Study.sf) %>%
      st_sf() %>%
      mutate(TOD = "Non-TOD")) 

st_write(TODtracts, "C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/Tract_map_TOD_0208.shp")

TODyes <- filter(TODtracts, TOD == "TOD")

ggplot() + 
  geom_sf(data=st_union(Study.sf)) +
  geom_sf(data=TODyes,
          aes(fill = TOD)) +
  geom_sf(data=DVRPC_railstops, 
          aes(colour = type_sym), 
          show.legend = "point", size= 2) +
  geom_sf(data = unionbuffer, fill = "transparent", color = "red")+
  scale_colour_manual(values = c("#ff8f1c", "#007dc3", "#781d7e", "#005DAA", "#EF3E42","#00A5E3", "#EF3E42", "#0255a1","#5d9731")) +
  labs(title="TOD tracts in DVRPC", 
       subtitle="Philadelphia, PA", 
       caption="Figure xx") +
  mapTheme()

st_write(TODyes, "C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/TODtracts.shp")

DVRPC_P <- 
  rbind(
    st_read("https://opendata.arcgis.com/datasets/45e0360128aa40448303c6458ca1a075_0.geojson") %>% 
      select(facility, type, line, service, county, state))%>%
  st_transform(st_crs(Study.sf))  %>%
  mutate(area = st_area(DVRPC_P))

DVRPC_Parcel <- st_read("C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/raw_data/Greater_Philadelphia_2015_Land_Use.shp")%>%
  st_transform(st_crs(Study.sf))


TOD_parcel <- st_join(DVRPC_Parcel, TODyes, join = st_contains)%>%
  dplyr::select(-GEOID, -NAME, -TotalPp, -White, -Black, -Asian, -Hspnc_L, -Pvrty_r, -MedIncm, -own_hsn, -rt_hwng, -TotalHH, -Totallt, -Vcnt_lt, -State, -County, -TOD)%>%
  st_sf()

ggplot() +
  geom_sf(data=st_union(Study.sf)) +
  geom_sf(data=st_union(TOD_parcel)) +
  labs(caption = "Figure xx") +
  mapTheme()

TOD_parcel2 <- TOD_parcel

st_write(TOD_parcel, "C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/TOD_parcels.csv")
