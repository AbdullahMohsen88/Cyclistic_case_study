################################# Environments #################################
# Setting up my environment 
library(tidyverse)
library(dplyr)
library(lubridate)
library(kableExtra)
library(ggplot2)
library(hms)
library(scales)
library(readr)
install.packages("rmarkdown")

################################# Pre-processing ###############################

# Setting the file path and reading the data
setwd("~/R/Case_Studies/Cyclistic/01_Data/Raw")
trips_2019 <- read.csv("Divvy_Trips_2019_Q1.csv")
trips_2020 <- read.csv("Divvy_Trips_2020_Q1.csv")

# Inspect data
colnames(trips_2019)
colnames(trips_2020)
View(trips_2019)
View(trips_2020)

# Checking for NA values
colSums(is.na(trips_2019))
colSums(is.na(trips_2020))

# Checking for duplicated records
nrow(trips_2019[duplicated(trips_2019),])
nrow(trips_2020[duplicated(trips_2020),])

# Selecting relevant columns and removing NA records
trips_2019_v2 <- trips_2019 %>% 
  select(trip_id,from_station_id,from_station_name,start_time,to_station_id,
         to_station_name,end_time,usertype) %>% 
  na.omit()
trips_2020_v2 <- trips_2020 %>% 
  select(ride_id,start_station_id,start_station_name,started_at,end_station_id,
         end_station_name,ended_at,member_casual) %>% 
  na.omit()

# Checking for duplicated records
nrow(trips_2019_v2[duplicated(trips_2019_v2$trip_id),])
nrow(trips_2020_v2[duplicated(trips_2020_v2$ride_id),])

################################# Processing ###################################

clean_and_add_duration <- function(df,
                                   start_col, end_col,
                                   station_from_col, station_to_col,
                                   user_col) {
  df %>%
    mutate(
      id = row_number(),
      
      start_at = ymd_hms({{ start_col }}),
      end_at   = ymd_hms({{ end_col }}),
      
      year  = year(start_at),
      month = month(start_at, label = TRUE, abbr = TRUE),
      day   = wday(start_at, label = TRUE, abbr = TRUE),
      
      # Keep characterible string version for display
      start_time = format(start_at, "%H:%M:%S"),
      end_time   = format(end_at,   "%H:%M:%S"),
      
      start_station_name = {{ station_from_col }},
      end_station_name   = {{ station_to_col }},
      user_type          = {{ user_col }},
      
      # === Extract hms directly from POSIXct ===
      start_hms = as_hms(start_at),
      end_hms   = as_hms(end_at),
      
      trip_seconds = case_when(
        end_hms >= start_hms ~ as.numeric(end_hms - start_hms),
        end_hms <  start_hms ~ as.numeric(end_hms - start_hms) + 24 * 3600
      ),
      
      trip_length = as_hms(trip_seconds)
    ) %>%
    select(
      id, start_station_name, start_at, start_time,
      year, month, day, user_type,
      end_station_name, end_at, end_time,
      trip_length, trip_seconds
    )
}
# 2019
trips_2019_v3 <- clean_and_add_duration(
  trips_2019_v2,
  start_time,
  end_time,
  from_station_name,
  to_station_name,
  usertype
)

# 2020
trips_2020_v3 <- clean_and_add_duration(
  trips_2020_v2,
  started_at,
  ended_at,
  start_station_name,
  end_station_name,
  member_casual
)

trips_2019_v3 %>% filter(is.na(trip_length)) %>% nrow()
trips_2020_v3 %>% filter(is.na(trip_length)) %>% nrow()

  # === Checking ===#
trips_2019_v3 %>% 
  filter(start_time > "23:45:00" & end_time < "00:15:00") %>% 
  select(start_time, end_time, trip_length)

# binding the data and checking for duplicates
all_trips <- bind_rows(trips_2019_v3,trips_2020_v3) 

# Unifying the values in user_type
all_trips$user_type <- ifelse(all_trips$user_type %in% c('Subscriber','member'), 
                              'Annual member', 'Casual rider')

# removing special characters from the station names
all_trips_v2 <- all_trips %>% 
  mutate(start_station_name = gsub("[^[:alnum:]& ]", "", all_trips$start_station_name),
         end_station_name = gsub("[^[:alnum:]& ]", "", all_trips$end_station_name))

write_csv(all_trips_v2, "all_trips_v2.csv")
