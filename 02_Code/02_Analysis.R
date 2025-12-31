################################# Calculations #################################

# === Average Trip Length === #

avg_trip_len <- all_trips_v2 %>%
  summarise(
    total_trips = n(),
    avg_duration_hms = as_hms(round(mean(trip_seconds) / 60) * 60),
  )

# === Average Trips Summary === #

avg_trip_summ <- all_trips_v2 %>%
  group_by(year, user_type) %>%
  summarise(
    n_trips  = n(),
    avg_duration_min  = round(mean(trip_seconds / 60), 2), # Minutes, 2 decimals
    .groups = "drop")

# === Average Trips Weekly Summary === #

avg_weekly_summ <- all_trips_v2 %>%
  group_by(day) %>%
  summarise(
    n_trips  = n(),
    avg_duration_min  = round(mean(trip_seconds / 60), 2), # Minutes, 2 decimals
    .groups = "drop"
  ) %>% 
  mutate(
    day = factor(day, levels = c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")))  

avg_weekly_casual <- all_trips_v2 %>%
  filter(user_type == "Casual rider") %>% 
  group_by(day) %>%
  summarise(
    n_trips  = n(),
    avg_duration_min  = round(mean(trip_seconds / 60), 2), # Minutes, 2 decimals
    .groups = "drop"
  ) %>% 
  mutate(
    day = factor(day, levels = c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"))) 

# === Average Trips Weekly Summary by User Type === #

avg_weekly_summ_user <- all_trips_v2 %>%
  group_by(year, user_type, day) %>%
  summarise(
    n_trips  = n(),
    avg_duration_min  = round(mean(trip_seconds / 60), 2), # Minutes, 2 decimals
    .groups = "drop"
  ) %>% 
  mutate(
    day = factor(day, levels = c("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")))  

# === Maximum trips summary === #

max_trip_summary <- all_trips_v2 %>% 
  group_by(year, user_type) %>% 
  summarise(
    max_trip_len = hms::as_hms(round(max(trip_seconds)/ 60, 2)),
    .groups = "drop")

# === Total Trips Summary === #
all_trips_v2 %>%
  group_by(year, user_type, day) %>%
  summarise(mean_time = mean(as.numeric(trip_length), na.rm = TRUE), .groups = "drop") %>%
  mutate(mean_time_hms = hms::as_hms(mean_time))

# === Frequency by Time === #

trips_binned <- all_trips_v2 %>%
  filter(user_type == "Casual member") %>% 
  mutate(
    time_bin = floor_date(start_at, "1 hour"),
    time_of_day = as_hms(time_bin)) %>%
  count(time_of_day, name = "n") %>%
  complete(time_of_day = hms(seq(0, 23*3600, 3600)), fill = list(n = 0))

peak_hour <- trips_binned %>%
  slice_max(n, n = 1) %>%
  mutate(
    peak_label = paste0(format(time_of_day, "%H:%M"), "\n",
                        scales::comma(n), " trips"))


# === Days with the Most Trips by Casual Riders === #

casual_busiest <- all_trips_v2 %>% 
  filter(user_type == "Casual rider") %>% 
  count(day, sort = TRUE, name = "Trips")

# === Top 5 Most Visited Stations by Casual Riders === #

busiest_stations_casual <- all_trips_v2 %>%
  filter(user_type == "Casual rider") %>% 
  group_by(start_station_name) %>% 
  summarize(trips = n()) %>% 
  ungroup() %>%
  arrange(desc(trips)) %>%
  slice_head( n = 5)
