library(tidyverse)
library(ggvis)
library(shiny)

enableBookmarking(store = "url")

ach_profile <- read_csv("data/achievement_profile_data_with_CORE.csv") %>%
    filter(!is.na(Region)) %>%
    mutate(Enrollment = ifelse(District == "State of Tennessee", NA, Enrollment),
        opacity = ifelse(District == "State of Tennessee", 1, 0.4))

# District characteristics for x variable
district_char <- c("Student Enrollment" = "Enrollment",
   "Percent Black Students" = "Black",
   "Percent Hispanic Students" = "Hispanic",
   "Percent Native American Students" = "Native American",
   "Percent English Learners" = "English Learners",
   "Percent Economically Disadvantaged" = "Economically Disadvantaged",
   "Percent Students with Disabilities" = "Students with Disabilities",
   "Per-Pupil Expenditures" = "Per-Pupil Expenditures",
   "Percent Black/Hispanic/Native American Students" = "Black/Hispanic/Native American",
   "Chronic Absence Rate" = "Chronic Absence",
   "Suspension Rate" = "Suspension Rate",
   "Expulsion Rate" = "Expulsion Rate")

# Outcomes for y variable
district_out <- c("Math Percent Proficient or Advanced" = "Math",
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
    "Graduation Rate" = "Graduation Rate",
    "Dropout Rate" = "Dropout Rate",
    "Chronic Absence Rate" = "Chronic Absence",
    "Suspension Rate" = "Suspension Rate",
    "Expulsion Rate" = "Expulsion Rate")

# Categoricals for fill
district_cat <- c("CORE Region" = "Region",
    "2015 Accountability Status" = "Accountability Status")

# District list for highlighting
district_list <- c(" " = "State of Tennessee", sort(ach_profile[-1, ]$District))

# Ranges for slider
ranges <- ach_profile %>%
    select(Enrollment:`Dropout Rate`) %>%
    gather(Characteristic, Value, Enrollment:`Dropout Rate`) %>%
    group_by(Characteristic) %>%
    summarise(Min = min(Value, na.rm = TRUE), Max = max(Value, na.rm = TRUE))
