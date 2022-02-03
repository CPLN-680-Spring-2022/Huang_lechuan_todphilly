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

variable19 <-
  load_variables(2019, "acs5", cache = TRUE)

#B01001_001 Total Population B11016_001 Housholed
#B02001_002 White alone, B02001_003 Black, B02001_004 Native, B02001_005 Asian, B03001_003 Hispanic or Latinx
#B06011_001 Median Income, B05010_001 Poverty Rate, B07013_002 owner housing, B07013_003 renter housing
#B19119_001 Total HH, B19119_002 2-person hh, B19119_003 3-person hh, B19119_004 4-person hh, B19119_005 5-person hh, B19119_006 6-person hh, B19119_007 >7hh
#B25002_001 Total B25002_002 Occupied B25002_003 Vacant

PA <- get_acs(geography = "tract", variables = c("B01001_001", "B11016_001", "B02001_002", "B02001_003", "B02001_005", "B03001_003",
                                                 "B06011_001", "B05010_001", "B07013_002", "B07013_003",
                                                 "B25002_001", "B25002_003"), 
              year=2019, state=42, county=c(101, 091, 045, 029, 017), geometry=T)%>% #101 = Philco, 091 = Montgomery, 045 = Delco, 029 = Chesco, 017= Bucks
  dplyr::select(-moe)%>%
  spread(variable, estimate)%>%
  rename(TotalPop = B01001_001, TotalHH = B11016_001,
         White = B02001_002, Black = B02001_003, Asian = B02001_005, Hispanic_Latinx = B03001_003,
         MedIncome = B06011_001, Poverty_rt = B05010_001, own_housing = B07013_002, rt_houwing = B07013_003,
         Totallot = B25002_001, Vacant_lot = B25002_003)

NJ <- get_acs(geography = "tract", variables = c("B01001_001", "B11016_001", "B02001_002", "B02001_003", "B02001_005", "B03001_003",
                                                 "B06011_001", "B05010_001", "B07013_002", "B07013_003",
                                                 "B25002_001", "B25002_003"), 
              year=2019, state=34, county=c(007, 005, 015, 021), geometry=T)%>% #007 Camden, 005 Burlington, 015 Gloucester, 021 Mercer
  dplyr::select(-moe)%>%
  spread(variable, estimate)%>%
  rename(TotalPop = B01001_001, TotalHH = B11016_001,
         White = B02001_002, Black = B02001_003, Asian = B02001_005, Hispanic_Latinx = B03001_003,
         MedIncome = B06011_001, Poverty_rt = B05010_001, own_housing = B07013_002, rt_houwing = B07013_003,
         Totallot = B25002_001, Vacant_lot = B25002_003)

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

DVRPC_railstops <- 
  rbind(
    st_read("https://opendata.arcgis.com/datasets/119efe00325947e988db8b3966151a92_0.geojson") %>% 
      mutate(Line = "Metro",) %>%
      select(station, line, operator, state))%>%
  st_transform(st_crs(Study.sf))  


DVRPC_railstops <- filter(DVRPC_railstops, operator != "Amtrak")%>%
  mutate(type_sym = ifelse(line == "Market/Frankford Line", "MFL",
                       ifelse(line == "Broad Street Line", "BSL",
                              ifelse(line == "PATCO", "PATCO",
                                     ifelse(line == "Norristown High Speed Line", "NHSL",
                                            ifelse(line == "River Line", "NJT_RiverLine",
                                                   ifelse(line == "Northeast Corridor", "NJT_NEC",
                                                          ifelse(line == "Atlantic City Line", "NJT_Atlantic",
                                                                 ifelse(line == "RiverLine", "NJT_Riverline",
                                                                        ifelse(line == "Route 101 & 102 Trolley Lines" |line == "Route 101 Trolley" |line == "Route 102 Trolley", "Trolley", "SEPTA_RR"))))))))))



DVRPC_railstops <- filter(DVRPC_railstops, state != "Delaware")%>%
  mutate(type = ifelse(type_sym == "MFL" | type_sym == "BSL" | type_sym == "PATCO", "Transit_Rail",
                       ifelse(type_sym == "NHSL" | type_sym == "NJT_Riverline", "Light_Rail",
                                     ifelse(type_sym == "Trolley", "Trolley", "Regional_Rail"))))%>%
  dplyr::select(-state)

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
  rbind(st_buffer(DVRPC_railstops, 2640) %>%
      mutate(Legend = "Buffer") %>%
      dplyr::select(Legend),
    st_union(st_buffer(DVRPC_railstops, 2640)) %>%
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

Vacantlots <- filter(Study.sf, TotalPop > 500)%>%
  dplyr::select(GEOID, NAME, TotalPop, Totallot, Vacant_lot)%>%
  mutate(pct_vacant = (Vacant_lot/Totallot) * 100)

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
