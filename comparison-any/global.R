library(tidyverse)
library(shiny)
library(ggvis)

ach_profile <- read_csv("data/achievement_profile_data_with_CORE.csv")

historical <- read_csv("data/historical_data.csv")

# Outcome vector for select input
outcome_list <- c("Math Percent Proficient or Advanced" = "Math",
    "English Language Arts Percent Proficient or Advanced" = "ELA",
    "Science Percent Proficient or Advanced" = "Science",
    "Algebra I Percent Proficient or Advanced" = "Algebra I",
    "Algebra II Percent Proficient or Advanced" = "Algebra II",
    "Biology I Percent Proficient or Advanced" = "Biology I",
    "Chemistry Percent Proficient or Advanced" = "Chemistry",
    "English I Percent Proficient or Advanced" = "English I",
    "English II Percent Proficient or Advanced" = "English II",
    "English III Percent Proficient or Advanced" = "English III",
    "Math Proficiency Growth" = "Math Growth",
    "English Language Arts Proficiency Growth" = "ELA Growth",
    "Science Proficiency Growth" = "Science Growth",
    "Algebra I Proficiency Growth" = "Algebra I Growth",
    "Algebra II Proficiency Growth" = "Algebra II Growth",
    "Biology I Proficiency Growth" = "Biology I Growth",
    "Chemistry Proficiency Growth" = "Chemistry Growth",
    "English I Proficiency Growth" = "English I Growth",
    "English II Proficiency Growth" = "English II Growth",
    "English III Proficiency Growth" = "English III Growth",
    "Average ACT Composite Score" = "ACT Composite",
    "Graduation Rate" = "Graduation",
    "Dropout Rate" = "Dropout",
    "Chronic Absence Rate" = "Chronic Absence",
    "Suspension Rate" = "Suspension Rate",
    "Expulsion Rate" = "Expulsion Rate")
