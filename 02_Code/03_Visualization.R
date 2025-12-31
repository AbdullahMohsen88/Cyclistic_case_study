################################ Visualization #################################

#=== Number of Trips by User Types ===#

trips_plot <- ggplot(all_trips_v2, aes(x = user_type, fill = user_type)) +
  geom_bar(width = 0.7, alpha = 0.9) +
  geom_label(
    stat = "count",
    aes(label = scales::comma(after_stat(count))),
    vjust = -0.5,
    size = 3.8,
    fill = "white",
    label.size = 0.25,
    label.padding = unit(0.15, "lines")) +
  facet_wrap(~ year) +
  scale_y_continuous(
    labels = scales::comma,
    expand = expansion(mult = c(0, 0.18))) +
  scale_fill_brewer(palette = "Set2") +
  labs(
    title = "Number of Trips by Customer Type",
    subtitle = "Total trips per customer type (2019 vs 2020)",
    x = "Customer Type",
    y = "Number of Trips",
    caption = "Source: Divvy bikes Jan 2019 to Mar 2019 and Jan 2020 to Mar 2020") +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "none",
    plot.subtitle = element_text(color = "gray40"),
    plot.caption = element_text(hjust = 0),
    panel.grid.minor = element_blank(),
    panel.border = element_rect(color = "gray80", fill = NA, linewidth = 0.5))

ggsave("trips_plot.png", plot = trips_plot, width = 8, height = 4.95, 
       dpi = 300)

#=== Average trip Duration Plot by year ===#

avg_trip_plot <- ggplot(avg_trip_summ, aes(x = user_type, y = avg_duration_min, 
                                           fill = user_type)) +
  geom_col(width = 0.7) + 
  geom_label(
    aes(label = paste(avg_duration_min, "min")),
    vjust = -0.5,
    size = 3.3,
    fill = "white",
    label.size = 0.25,
    label.padding = unit(0.15, "lines"))+  facet_wrap(~ year) + 
  #scale_y_continuous(breaks = seq(0, 60, 10)) + 
  labs(
    title = "Average Trip Duration for Customer Types", 
    subtitle = "Comparison of average duration (2019 vs 2020)", 
    x = "Customer Type", 
    y = "Average Duration (minutes)",
    caption = "Source: Divvy bikes Jan 2019 to Mar 2019 and Jan 2020 to Mar 2020") +
  scale_fill_brewer(palette = "Set2") +
  ylim(0,50)+
  theme_minimal() + 
  guides(fill = "none") +
  theme(plot.subtitle = element_text(color = "gray40"),
        legend.position = "top",
        plot.caption = element_text(hjust = 0),
        panel.border = element_rect(color = "gray80", fill = NA, linewidth = 0.5))

ggsave("avg_trip_plot.png", plot = avg_trip_plot, width = 8, height = 4.95, 
       dpi = 300)

#=== Number of Trips Plot by Day of the Week ===#

weekly_trips_plot <- ggplot(avg_weekly_summ_user, aes(x = day, y = n_trips, 
                                                      color = user_type, 
                                                      group = user_type)) +
  geom_smooth(se = FALSE, linewidth = 1, span = 0.6) +
  geom_point(size = 2, shape = 21, fill = "white", stroke = 1.5) +
  scale_y_continuous(
    labels = comma,
    limits = c(0, 80000),
    expand = expansion(mult = c(0, 0.1))) +
  scale_color_brewer(palette = "Set2") +
  labs(
    title = "Weekly Trips Summary by Customer Type",
    subtitle = "Weekly patterns",
    x = "Day of Week",
    y = "Number of Trips",
    caption = "Source: Divvy bikes Jan 2019 to Mar 2019 and Jan 2020 to Mar 2020",
    color = "Customer Type") +
  theme_minimal(base_size = 13) +
  theme(
    plot.subtitle = element_text(color = "gray40"),
    legend.position = "top",
    plot.caption = element_text(hjust = 0),
    panel.grid.minor = element_blank(),
    panel.border = element_rect(color = "gray80", fill = NA, linewidth = 0.5))

ggsave("weekly_trips_plot.png", plot = weekly_trips_plot, width = 8, height = 4.95, 
       dpi = 300)

#=== Daily Average Duration ===#

avgWeeklyCasual_plot <- ggplot(avg_weekly_casual, aes(y = avg_duration_min, 
                                                      x = day, fill = day)) +
  geom_col(width = 0.7) +
  geom_label(
    aes(label = paste(avg_duration_min, "min")),
    vjust = -0.5,
    size = 3.3,
    fill = "white",
    label.size = 0.25,
    label.padding = unit(0.15, "lines"))+
  labs(
    x = "Day of week", 
    y = "Average duration (minutes)", 
    title = "Average Trip Duration by Day", 
    subtitle = "Average trip duration for Casual rider by day",
    caption = "Source: Divvy bikes Jan 2019 to Mar 2019 and Jan 2020 to Mar 2020") +
  scale_fill_brewer(palette = "Set2") +
  ylim(0,60) +
  theme_minimal() +
  theme(plot.subtitle = element_text(color = "gray40"),
        legend.position = "none",
        plot.caption = element_text(hjust = 0),
        panel.border = element_rect(color = "gray80", fill = NA, linewidth = 0.5))

ggsave("avgWeeklyCasual_plot.png", plot = avgWeeklyCasual_plot, width = 8, height = 4.95, 
       dpi = 300)

#=== Peak Hours Plot ===#

busiestHours_plot <- ggplot(trips_binned, aes(x = time_of_day, y = n)) +
  geom_col(fill = "#42A5F5", width = 3400, alpha = 0.92) +  # ~1-hour width
  geom_label(
    data = peak_hour,
    aes(label = peak_label),
    vjust = -0.5,
    size = 3.3,
    fill = "white",
    label.size = 0.3,
    label.padding = unit(0.25, "lines")) +
  scale_x_time(
    labels = time_format("%H:%M"),
    breaks = hms(hours = 0:23),
    expand = expansion(mult = c(0.01, 0.01))) +
  #scale_y_continuous(labels = comma, expand = expansion(mult = c(0, 0.18))) +
  ylim(0,10000) +
  labs(
    title = "Busiest Hours of Day",
    subtitle = "Peak hours for Casual rider",
    x = "Start Time (24h)",
    y = "Number of Trips",
    caption = "Source: Divvy bikes Jan 2019 to Mar 2019 and Jan 2020 to Mar 2020") +
  theme_minimal(base_size = 13) +
  theme(
    plot.subtitle = element_text(color = "gray50"),
    panel.grid.minor = element_blank(),
    plot.caption = element_text(hjust = 0),
    axis.text.x = element_text(angle = 0))

ggsave("busiestHours_plot.png", plot = busiestHours_plot, width = 8, height = 4.95, 
       dpi = 300)

#=== Top 5 Most Busiest Stations ===#

busiestStations_plot <- ggplot(busiest_stations_casual, 
                               aes(x = trips, y = reorder(start_station_name, trips), 
                                   fill = start_station_name)) +
  geom_col(width = 0.7, alpha = 0.9) +
  geom_label(
    aes(label = paste(trips, "trips")),    
    hjust = -0.1,
    size = 3.8,
    fill = "white",
    label.size = 0.25,
    label.padding = unit(0.15, "lines")) +
  scale_x_continuous(
    labels = scales::comma,
    expand = expansion(mult = c(0, 0.18))) +
  scale_fill_brewer(palette = "Set2") +
  labs(
    title = "Top 5 Most Busiest Stations by Casual Rider",
    subtitle = "Stations with the most trips started by Casual rider",
    x = "Number of Trips",
    y = "Station names") +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "none",
    plot.subtitle = element_text(color = "gray40"),
    panel.grid.minor = element_blank(),
    panel.border = element_rect(color = "gray80", fill = NA, linewidth = 0.5))

ggsave("busiestStations_plot.png", plot = busiestStations_plot, width = 8, height = 4.95, 
       dpi = 300)

