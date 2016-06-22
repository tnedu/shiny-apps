library(dplyr)
library(ggvis)
library(formattable)
library(ReporteRs)
library(shinydashboard)

participation <- read.csv("data/participation_master.csv", stringsAsFactors = FALSE)

performance_gate <- read.csv("data/performance_gate_master.csv", stringsAsFactors = FALSE)
achievement <- read.csv("data/achievement_master.csv", stringsAsFactors = FALSE)

achievement[achievement$subject == "ELA" & achievement$grade == "3rd through 5th", ]$subject <- "3-5 ELA"
achievement[achievement$subject == "ELA" & achievement$grade == "6th through 8th", ]$subject <- "6-8 ELA"
achievement[achievement$subject == "Math" & achievement$grade == "3rd through 5th", ]$subject <- "3-5 Math"
achievement[achievement$subject == "Math" & achievement$grade == "6th through 8th", ]$subject <- "6-8 Math"

gap_closure <- read.csv("data/gap_closure_master.csv", stringsAsFactors = FALSE)

gap_closure[gap_closure$subject == "ELA" & gap_closure$grade == "3rd through 5th", ]$subject <- "3-5 ELA"
gap_closure[gap_closure$subject == "ELA" & gap_closure$grade == "6th through 8th", ]$subject <- "6-8 ELA"
gap_closure[gap_closure$subject == "Math" & gap_closure$grade == "3rd through 5th", ]$subject <- "3-5 Math"
gap_closure[gap_closure$subject == "Math" & gap_closure$grade == "6th through 8th", ]$subject <- "6-8 Math"

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

ach_profile <- read.csv("data/achievement_profile_data.csv", stringsAsFactors = FALSE) %>% 
    filter(system != 0)

outcome_list <- c("Math Percent Proficient or Advanced" = "Math",
                  "English Language Arts Percent Proficient or Advanced" = "ELA",
                  "Science Percent Proficient or Advanced" = "Science",
                  "Algebra I Percent Proficient or Advanced" = "AlgI",
                  "Algebra II Percent Proficient or Advanced" = "AlgII",
                  "Biology I Percent Proficient or Advanced" = "BioI",
                  "Chemistry Percent Proficient or Advanced" = "Chemistry",
                  "English I Percent Proficient or Advanced" = "EngI",
                  "English II Percent Proficient or Advanced" = "EngII",
                  "English III Percent Proficient or Advanced" = "EngIII",
                  "Graduation Rate" = "Graduation",
                  "Dropout Rate" = "Dropout",
                  "Average ACT Composite Score" = "ACT_Composite",
                  "Chronic Absenteeism" = "Pct_Chronically_Absent",
                  "Suspension Rate" = "Pct_Suspended",
                  "Expulsion Rate" = "Pct_Expelled")