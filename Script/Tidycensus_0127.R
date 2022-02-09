library(tidycensus)
library(ggplot2)
library(tidyverse)
library(rgdal)
library(sf)

root.dir = "https://raw.githubusercontent.com/urbanSpatial/Public-Policy-Analytics-Landing/master/DATA/"
source("https://raw.githubusercontent.com/urbanSpatial/Public-Policy-Analytics-Landing/master/functions.r")

census_api_key("3050a770b2aedfa128dd2ccc6ca8b8524fccc775", overwrite = TRUE)

palette5 <- c("#25CB10", "#5AB60C", "#8FA108",   "#C48C04", "#FA7800")

variable19 <-
  load_variables(2019, "acs5", cache = TRUE)

#B01001_001 Total Population
#B02001_002 White alone, B02001_003 Black, B02001_004 Native, B02001_005 Asian, B03001_003 Hispanic or Latinx
#B06011_001 Median Income, B05010_001 Poverty Rate, B07013_002 owner housing, B07013_003 renter housing
#B19119_001 Total HH, B19119_002 2-person hh, B19119_003 3-person hh, B19119_004 4-person hh, B19119_005 5-person hh, B19119_006 6-person hh, B19119_007 >7hh

PA <- get_acs(geography = "tract", variables = c("B01001_001", "B02001_002"), 
          year=2019, state=42, county=c(101, 091, 045, 029, 017), geometry=T)%>% #101 = Philco, 091 = Montgomery, 045 = Delco, 029 = Chesco, 017= Bucks
  dplyr::select(-moe)%>%
  spread(variable, estimate) 

NJ <- get_acs(geography = "tract", variables = c("B01001_001", "B02001_002"), 
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
                                                                           ifelse(startsWith(GEOID, "34021"), "Mercer", ""))))))))))

ggplot() + 
  geom_sf(data = Study.sf)

st_write(Study.sf, "C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/raw_data/Ticycensus/Tract_map_initial.shp")
