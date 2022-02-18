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

PA <- get_acs(geography = "tract", variables = c("B01001_001", "B11016_001", "B02001_002", "B02001_003", "B02001_005", "B03001_003",
                                                 "B06011_001", "B05010_001", "B07013_002", "B07013_003",
                                                 "B25002_001", "B25002_003", "B25031_001"), 
              year=2019, state=42, county=c(101, 091, 045, 029, 017), geometry=T)%>% #101 = Philco, 091 = Montgomery, 045 = Delco, 029 = Chesco, 017= Bucks
  dplyr::select(-moe)%>%
  spread(variable, estimate)

NJ <- get_acs(geography = "tract", variables = c("B01001_001", "B11016_001", "B02001_002", "B02001_003", "B02001_005", "B03001_003",
                                                 "B06011_001", "B05010_001", "B07013_002", "B07013_003",
                                                 "B25002_001", "B25002_003", "B25031_001"), 
              year=2019, state=34, county=c(007, 005, 015, 021), geometry=T)%>% #007 Camden, 005 Burlington, 015 Gloucester, 021 Mercer
  dplyr::select(-moe)%>%
  spread(variable, estimate)

Study.sf <- rbind(NJ, PA)%>%
  mutate(State = ifelse(startsWith(GEOID, "42"), "Pennsylvania", ifelse(startsWith(GEOID, "34"), "New Jersey", "")),
         County = ifelse(startsWith(GEOID, "42101"), "Philadelphia", 
                         ifelse(startsWith(GEOID, "42091"), "Montgomery", 
                                ifelse(startsWith(GEOID, "42045"), "Delaware",
                                       ifelse(startsWith(GEOID, "42029"), "Chester",
                                              ifelse(startsWith(GEOID, "42017"), "Bucks",
                                                     ifelse(startsWith(GEOID, "34007"), "Camden",
                                                            ifelse(startsWith(GEOID, "34005"), "Burlington",
                                                                   ifelse(startsWith(GEOID, "34015"), "Gloucester",
                                                                          ifelse(startsWith(GEOID, "34021"), "Mercer", ""))))))))))%>%
  dplyr::rename(TotalPop = B01001_001, TotalHH = B11016_001,
         White = B02001_002, Black = B02001_003, Asian = B02001_005, Hispanic_Latinx = B03001_003,
         MedIncome = B06011_001, Poverty_rt = B05010_001, own_housing = B07013_002, rt_houwing = B07013_003,
         Totallot = B25002_001, Vacant_lot = B25002_003, MedRent= B25031_001)

Study.sf2 <- filter(Study.sf, GEOID %in% TODyes$GEOID)


PAWater <- area_water('PA', county = c('Philadelphia', 'Delaware', 'Chester', 'Montgomery', 'Bucks')) %>%
  st_as_sf()%>%
  st_transform(crs=4326)

NJWater <- area_water('NJ', county = c('Camden', 'Burlington', 'Gloucester', 'Mercer')) %>%
  st_as_sf()%>%
  st_transform(crs=4326) 

Water <- rbind(NJWater, PAWater)

Water <- filter(Water, AWATER > 1500)

st_write(Water, "C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/raw_data/Water_1500.shp")


geom_sf(data = st_union(Water), color = 'blue')+
  
ggplot()+
  geom_sf(data = st_union(Study.sf))+
  geom_sf(data=Study.sf2,
          aes(fill = q5(MedRent))) +
  scale_fill_manual(values = palette5,
                    labels = qBr(Study.sf2, "MedRent"),
                    name = "Popluation\n(Quintile Breaks)") +
  labs(title = "Median Rent among TOD tracts", subtitle = "DVRPC") +
  mapTheme() + 
  theme(plot.title = element_text(size=22))

ggplot()+
  geom_sf(data = st_union(Study.sf))+
  geom_sf(data=Study.sf2,
          aes(fill = q5(MedIncome))) +
  scale_fill_manual(values = palette5,
                    labels = qBr(Study.sf2, "MedIncome"),
                    name = "MedIncome \n(Quintile Breaks)") +
  labs(title = "Median Income among TOD tracts", subtitle = "DVRPC") +
  mapTheme() + 
  theme(plot.title = element_text(size=22))

##Tidycensus
Study.sf2 <- Study.sf2%>%
  mutate(White_PCT = (White/TotalPop) * 100,
         Black_PCT = (Black/TotalPop) * 100,
         Asian_PCT = (Asian/TotalPop) * 100,
         Latinx_PCT = (Hispanic_Latinx/TotalPop) * 100,
         Poverty_PCT = (Poverty_rt/TotalPop) * 100,
         own_hou_rate = (own_housing/TotalPop) * 100)

#GGPLOT

ggplot()+
  geom_sf(data = st_union(Study.sf))+
  geom_sf(data=Study.sf2,
          aes(fill = q5(own_hou_rate))) +
  scale_fill_manual(values = palette5,
                    labels = qBr(Study.sf2, "own_hou_rate"),
                    name = "own_hou_rate \n(Quintile Breaks)") +
  labs(title = "Percentage of people living in own properties among TOD tracts", subtitle = "DVRPC") +
  mapTheme() + 
  theme(plot.title = element_text(size=22))
