# Load packages.
library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)
library(cowplot)
library(stringr)
library(purrr)

# Scientific notation off.
options(scipen=99999)

# Extract list of working directories + file names for each csv in the recent 36-month download.
file_names <- paste("data/met_police_june2017_to_may2020/", list.files("data/met_police_june2017_to_may2020", "*.csv", recursive=TRUE), sep = "")

# Loop through each and load.
met_list <- lapply(file_names, read_csv)

# Load missing 2017 months from the archive data (this could also be done as below for 2016, which is perhaps easier).
jan17 <- read_csv("data/archive_to_may_2017/2017-01/2017-01-metropolitan-street.csv")
feb17 <- read_csv("data/archive_to_may_2017/2017-02/2017-02-metropolitan-street.csv") 
mar17 <- read_csv("data/archive_to_may_2017/2017-03/2017-03-metropolitan-street.csv") 
apr17 <- read_csv("data/archive_to_may_2017/2017-04/2017-04-metropolitan-street.csv")
may17 <- read_csv("data/archive_to_may_2017/2017-05/2017-05-metropolitan-street.csv")

# Extract the Met 2016 from archive data.
dates_2016 <- list.files("data/archive_to_may_2017", pattern = "2016")
extra <- paste("data/archive_to_may_2017", "/", dates_2016, "/", dates_2016, "-", "metropolitan-street.csv", sep = "")
met_2016_list <- lapply(extra, read_csv)

# Bind everything together.
met_full_df <- bind_rows(met_list, jan17, feb17, mar17, apr17, may17, met_2016_list)

# Remove other crime. Separate object created (1) if needed, (2) for labels later.
met_full_df <- met_full_df %>% 
  filter(`Crime type` != "Other crime")

# Counts.
met_stats_list <- met_full_df %>%
  separate(Month, into = c("Year","Month"), sep = "-") %>% 
  group_by(Year, Month, `Crime type`) %>% 
  summarise(counts = n()) %>% 
  arrange(`Crime type`, Year, Month) %>% 
  ungroup() %>% 
  group_split(`Crime type`)

# Month vector. January blank to reflect end of month counts.
month_labs <- c(" ","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec")

# As below, I make the plot using a loop so that I can annotate them individually if needed.
# However, note that a similar version of the main plot could be made using facet_wrap() within
# ggplot! In which case, no loop would be needed.

# Base visual function.
plot_fun <- function(x){
  ggplot() +
    geom_line(data = filter(x, Year != 2020),
              mapping = aes(x = Month, y = counts, group = Year),
              colour = "lightgrey") +
    geom_vline(data = x,
               mapping = aes(xintercept = 2.7),
               linetype = "dotted") + 
    stat_summary(data = filter(x, Year != 2020),
                 aes(x = Month, y = counts, group = Year),
                 fun = mean, colour = "black", geom = "line", group=1, size = 0.7) +
    geom_line(data = filter(x, Year == 2020),
              mapping = aes(x = Month, y = counts, group = 1),
              colour = "tomato", size = 1) +
    scale_x_discrete(labels = month_labs) +
    scale_y_continuous(limits = c(0.6*min(x$counts), 1.4*max(x$counts)), n.breaks = 5) +
    labs(x = " ", y = " ") +
    theme_bw() +
    theme(axis.title = element_blank(),
          axis.text.x = element_blank(),
          axis.text.y = element_text(size = 6),
          axis.ticks = element_blank(),
          plot.title = element_text(size = 8))  
}

# Name for titles.
names(met_stats_list) <- sort(unique(met_full_df$`Crime type`))

# Make plots and add titles.
met_stats_plots <- list()
for (i in seq(met_stats_list)) {
  gg <- plot_fun(met_stats_list[[i]]) +
    labs(title = str_replace_all(string = names(met_stats_list[i]), "_", " "))
  met_stats_plots[[i]] <- gg
}

# Basic visual.
p1 <- plot_grid(plotlist = met_stats_plots, ncol = 3)
ggsave(p1, filename = "visuals/full_met_basic.png", height = 8, width = 6)

# Get out ASB plot out for bespoke plotting with labels.
Anti_social_behaviour <- pluck(met_stats_plots, 1)

# Arrange and annotate.
asb <- Anti_social_behaviour +
  theme(axis.text.x = element_text(size = 6, angle = 90, vjust = -1.5)) +
  labs(title = "Anti-social behaviour") +
  #2020 label
  annotate(geom = "curve" , x = 7, y = 73000, xend = 5, yend = 61000,
           curvature = 0.3, arrow = arrow(length = unit(1, "mm"))) +
  annotate(geom = "text", x = 7.8, y = 73000, label = "2020", fontface = "bold", size = 3) +
  #lockdown label
  annotate(geom = "curve", x = 4, y = 9000, xend = 2.8, yend = 9000,
           curvature = 0.1, arrow = arrow(length = unit(1, "mm"))) +
  annotate(geom = "text", x = 5.5, y = 9000, label = "Lockdown", fontface = "bold", size = 3) +
  #recent years label
  annotate(geom = "curve", x = 8, y = 38500, xend = 8.3, yend = 26000,
           curvature = -0.1, arrow = arrow(length = unit(1, "mm"))) +
  annotate(geom = "text", x = 8, y = 43000, label = "Recent years (inc. mean)", fontface = "bold", size = 3) 


# Remove ASB for plot list to avoid repeat.
met_stats_plots[[1]] <- NULL

# Arrange with cowplot.
asb_blank <- plot_grid(asb, NULL, nrow = 1)
all_plots <- plot_grid(plotlist = met_stats_plots, nrow = 4)
full_plot <- plot_grid(asb_blank, all_plots, nrow = 2, rel_heights = c(2,5))

# Save main plot.
ggsave(full_plot, filename = "visuals/full_met.png", height = 8, width = 6)

