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

#Files
Final_parcel <- st_read("C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/800buffer/Final_parcel_analysis_area.shp")
Study.sf <- st_read("C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/Tract_map_TOD_0208.shp")
TODTracts <- st_read("C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/TODtracts.shp")
DVRPC_TOD <- st_read("C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/raw_data/DVRPC_TOD/TOD_Opportunities.shp")
DVRPC_railstops <- st_read("C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/Transitstations.shp")

DVRPC_railstops <- tibble::rowid_to_column(DVRPC_railstops, "ID")

#assign accessibility
#Trolley: 3-4/h C: 50
#SEPTA_main: 8/h  C:110
#SEPTA_Glenside: 3-4/h C:110
#Paoli: 2/h C:110
#Other Regional Rail: 0.5-1/h C:110
#Light Rail: 15min C: 70
#Rail_transit: C: 150
#BSL: 16
#BSL-Local-North: 12
#BSL South: 8 
#MFL: 12
#PATCO: 7

DVRPC_railstops <- DVRPC_railstops%>%
  mutate(capacity = ifelse(type == "Trolley", 50,
                            ifelse(type == "Light_Rail", 70,
                                   ifelse(type == "Regional_Rail", 110,
                                          ifelse(type == "Transit_Rail", 150, 0)))),
         freqe = ifelse(type == "Trolley", 3.5,
                       ifelse(type == "Light_Rail", 4,
                              ifelse(line == "SEPTA Main Line", 8,
                                     ifelse(line == "Glenside Combined", 3.5,
                                            ifelse(line == "PATCO", 7,
                                                   ifelse(line == "Market/Frankford Line", 12, 0.45)))))))


#BSL Express
DVRPC_railstops$freqe[DVRPC_railstops$ID %in% c("307", "225", "289","230", "274","3","314","200")] <- 16
#BSL South local & Chinatown
DVRPC_railstops$freqe[DVRPC_railstops$ID %in% c("318", "196", "227", "193", "228", "9", "231", "283")] <- 8
#BSL North Local
DVRPC_railstops$freqe[DVRPC_railstops$ID %in% c("217", "229", "234", "238", "277", "288", "309", "313")] <- 12
#NJT NEC
DVRPC_railstops$freqe[DVRPC_railstops$line %in% c("Paoli/Thorndale Line", "Northeast Corridor")] <- 2 

station_access <- DVRPC_railstops%>%
  dplyr::select(-freq)%>%
  mutate(access = capacity * freqe,
         ac_score = ntile(access, 10))


#aggregate by hand
#Trenton
station_access$ID[station_access$ID %in% c("31", "35", "40")] <- 31 
#North Philadelphia
station_access$ID[station_access$ID %in% c("108", "188", "287")] <- 277
#Camden (RIVERLINE + PATCO)
station_access$ID[station_access$ID %in% c("49", "156")] <- 49
#Lindenwold
station_access$ID[station_access$ID %in% c("165", "210")] <- 165
#Pennsauken
station_access$ID[station_access$ID %in% c("186", "253")] <- 253
#Fern Rock
station_access$ID[station_access$ID %in% c("116", "307")] <- 307
#69th St
station_access$ID[station_access$ID %in% c("4", "201", "282")] <- 4
#8th St
station_access$ID[station_access$ID %in% c("231", "237", "296")] <- 296
#Center City (15, City Hall, Suburban)
station_access$ID[station_access$ID %in% c("297", "260", "314")] <- 314
#Norristown
station_access$ID[station_access$ID %in% c("144", "284")] <- 144
#Jefferson 11th
station_access$ID[station_access$ID %in% c("48", "221")] <- 221

station_access_clea <- aggregate(access ~ ID, station_access, sum)%>%
  rename(sum_ac = access)

#add bus (determined by transportation center)
#Fern Rock 6, 69th 25, Norristown 10, Arrott 10, Olney 9m, Chester 9, Frankfort 25, Wissa 12.
station_access_clea$sum_ac[station_access_clea$ID %in% c("4")] <- 2255 + (25*50)
station_access_clea$sum_ac[station_access_clea$ID %in% c("87")] <- 49.5 + (12*50)
station_access_clea$sum_ac[station_access_clea$ID %in% c("144")] <- 329.5 + (10*50)
station_access_clea$sum_ac[station_access_clea$ID %in% c("195")] <- 1800 + (10*50)
station_access_clea$sum_ac[station_access_clea$ID %in% c("225")] <- 2400 + (9*50)
station_access_clea$sum_ac[station_access_clea$ID %in% c("255")] <- 49.5 + (9*50)
station_access_clea$sum_ac[station_access_clea$ID %in% c("272")] <- 1800 + (25*50)
station_access_clea$sum_ac[station_access_clea$ID %in% c("307")] <- 2785 + (6*50)

clean_station <- merge(x=station_access_clea,y=DVRPC_railstops,by="ID",all.x=TRUE)%>%
  mutate(ac_score = ntile(sum_ac, 10))%>%
  st_as_sf()%>%
  st_transform(4326)

#job data
#see also: https://www.dvrpc.org/Reports/ADR021.pdf
jobs <- st_read("https://opendata.arcgis.com/datasets/0635910b84204020b1c8474a4732f257_0.geojson")

jobs <- jobs%>%
  mutate(job35den = emp35/Shape__Area,
         job_sc = ntile(job30den, 10),
         pop35den = pop35/Shape__Area,
         jobsurp = emp35 - pop35,
         surp_sc = ntile(jobsurp, 10))%>%
  dplyr::select(objectid, co_name, mun_name, state, job_sc, emp35, pop35, job30den, pop35den, jobsurp, surp_sc, Shape__Area, geometry)%>%
  st_transform(4326)

job_join <- jobs%>%
  dplyr::select(job_sc, jobsurp, surp_sc)%>%
  mutate(surp_abs = abs(jobsurp),
         em_surp_sc = ntile(surp_abs, 10))%>%
  dplyr::select(job_sc, surp_sc, em_surp_sc)

ggplot() +
  geom_sf(data=job_join, aes(fill = em_surp_sc)) +
  labs(title="DVRPC's analysis of Station area", 
       subtitle="Job/Pop Surplus", 
       caption="Figure xx") +
  mapTheme()

clean_station_job <- st_join(clean_station, job_join, join = st_within, left= TRUE)

st_write(clean_station_job, "C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/final_mat/station_with_job_0407.shp")

#equity
#protect low income but low poverty rate
#protect high income low poverty rate
#protect high own house rate

social <- Study.sf%>%
  dplyr::select(NAME, TotalPp, TotalHH, MedIncm, Pvrty_r, rt_hwng)%>%
  mutate(pvt_rate = Pvrty_r/TotalPp,
         pvt_qn = ntile(-pvt_rate, 10),
         MdInm_qn = ntile(MedIncm, 10),
         aff_gp = abs(pvt_qn - MdInm_qn),
         gp_score = ntile(aff_gp, 10),
         ownh_rate = rt_hwng/TotalPp,
         own_hs_qn = ntile(-ownh_rate, 10))%>%
  st_transform(4326)#higher the score, the lower the rate

ggplot() +
  geom_sf(data=st_union(Study.sf)) +
  geom_sf(data=social, aes(fill = aff_gp)) +
  labs(title="DVRPC's analysis of Station area", 
       subtitle="+4 - Low Poverty Low Income; -4 High Income High Poverty", 
       caption="Figure xx") +
  mapTheme()

station_social <- st_join(clean_station_job, social, join = st_within, left= TRUE)

station_social_final <- station_social%>%
  dplyr::select(-NAME, -TotalPp, -TotalHH, -rt_hwng, -ownh_rate)%>%
  mutate(not_gen = ntile(-gp_score, 10))%>%
  dplyr::select(-MedIncm, -Pvrty_r, -pvt_rate, -aff_gp, -gp_score, -own_hs_qn)

gentrification <- filter(station_social, MedIncm<25000 & MedIncm>10000)%>% #outlier of college town
  dplyr::select(station, line, MedIncm, MdInm_qn, pvt_rate, pvt_qn, gp_score)%>%
  arrange(desc(gp_score))

st_write(gentrification, "C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/final_mat/gentrification_stations.shp")
write_csv(gentrification, "C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/final_mat/gentrification_stations.csv")

#VISUALIZATION
ggplot() +
  geom_sf(data=st_union(Study.sf)) +
  geom_sf(data=station_social_final, aes(colour = not_gen),
          show.legend = "point", size = 5) +
  labs(title="DVRPC's analysis of Station area", 
       subtitle="Station with low-affordability gaps around", 
       caption="Figure xx") +
  mapTheme()

st_write(station_social_final, "C:/Users/mnxan/OneDrive/Documents/GitHub/Huang_lechuan_todphilly/cleaned_data/final_mat/stations_access_jobs_census.shp")
