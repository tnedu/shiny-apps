library(tidyverse)
library(ggvis)
library(shiny)

enableBookmarking(store = "url")

df <- read_csv("data/achievement_profile_data_with_CORE.csv") %>%
    mutate(Enrollment = ifelse(system_name == "State of Tennessee", NA, Enrollment),
        opacity = ifelse(system_name == "State of Tennessee", 1, 0.4))

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
   "Percent Chronically Absent" = "Chronic Absence", 
   "Suspension Rate" = "Suspension Rate",
   "Expulsion Rate" = "Expulsion Rate")

# Outcomes for y variable
district_out <- c("Math Percent Proficient or Advanced" = "Math",
    "English Language Arts Percent Proficient or Advanced" = "ELA",
    "Science Percent Proficient or Advanced" = "Science",
    "Algebra I Percent Proficient or Advanced" = "Alg I",
    "Algebra II Percent Proficient or Advanced" = "Alg II",
    "Biology I Percent Proficient or Advanced" = "Biology I",
    "Chemistry Percent Proficient or Advanced" = "Chemistry",
    "English I Percent Proficient or Advanced" = "Eng I",
    "English II Percent Proficient or Advanced" = "Eng II",
    "English III Percent Proficient or Advanced" = "Eng III",
    "Math Proficiency Growth" = "Math Growth",
    "English Language Arts Proficiency Growth" = "ELA Growth",
    "Science Proficiency Growth" = "Science Growth",
    "Algebra I Proficiency Growth" = "Alg I Growth",
    "Algebra II Proficiency Growth" = "Alg II Growth",
    "Biology I Proficiency Growth" = "Bio I Growth",
    "Chemistry Proficiency Growth" = "Chemistry Growth",
    "English I Proficiency Growth" = "Eng I Growth",
    "English II Proficiency Growth" = "Eng II Growth",
    "English III Proficiency Growth" = "Eng III Growth",
    "Average ACT Composite Score" = "ACT Composite",
    "Graduation Rate" = "Graduation",
    "Dropout Rate" = "Dropout",
    "Percent Chronically Absent" = "Chronic Absence",
    "Suspension Rate" = "Suspension Rate",
    "Expulsion Rate" = "Expulsion Rate")

# District list for highlighting
district_list <- c(" " = "State of Tennessee", sort(df[-1, ]$system_name))

# Ranges for slider
ranges <- df %>%
    select(Enrollment:Dropout) %>%
    gather(Characteristic, Value, Enrollment:Dropout) %>%
    group_by(Characteristic) %>%
    summarise(Min = min(Value, na.rm = TRUE), Max = max(Value, na.rm = TRUE))
