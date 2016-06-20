library(dplyr)
library(ggvis)
library(formattable)
library(shinydashboard)

participation <- read.csv("data/participation_master.csv", stringsAsFactors = FALSE)
performance_gate <- read.csv("data/performance_gate_master.csv", stringsAsFactors = FALSE)
achievement <- read.csv("data/achievement_master.csv", stringsAsFactors = FALSE)
gap_closure <- read.csv("data/gap_closure_master.csv", stringsAsFactors = FALSE)

determinations <- read.csv("data/final_determinations.csv", stringsAsFactors = FALSE) %>%
    select(one_of(c("system_name", "minimum_performance_goal", "achievement_determination", 
                    "gap_determination", "final_determination")))

determinations[determinations$minimum_performance_goal == "", ]$minimum_performance_goal <- "N/A"
determinations[determinations$achievement_determination == "", ]$achievement_determination <- "N/A"
determinations[determinations$gap_determination == "", ]$gap_determination <- "N/A"
determinations[determinations$final_determination == "", ]$final_determination <- "N/A"

district_list <- unique(determinations$system_name)

color_list <- c("Met" = "blue",
                "Missed" = "red",
                "N/A" = "black",
                "In Need of Improvement" = "red",
                "Progressing" = "yellow",
                "Achieving" = "green",
                "Exemplary" = "blue")