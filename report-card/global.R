library(dplyr)
library(ggvis)
library(shinydashboard)

numeric <- read.csv("data/system_numeric_with_super_subgroup.csv", stringsAsFactors = FALSE)
determinations <- read.csv("data/final_determinations.csv", stringsAsFactors = FALSE) %>%
    select(one_of(c("system_name", "minimum_performance_goal", "achievement_determination", 
                    "gap_determination", "final_determination")))

determinations[determinations$minimum_performance_goal == "", ]$minimum_performance_goal <- "N/A"
determinations[determinations$achievement_determination == "", ]$achievement_determination <- "N/A"
determinations[determinations$gap_determination == "", ]$gap_determination <- "N/A"
determinations[determinations$final_determination == "", ]$final_determination <- "N/A"

district_list = unique(numeric$system_name)

color_list <- c("Met" = "blue",
                "Missed" = "red",
                "N/A" = "black",
                "In Need of Improvement" = "red",
                "Progressing" = "yellow",
                "Achieving" = "green",
                "Exemplary" = "blue"
)