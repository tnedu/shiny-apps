library(tidyr)
library(dplyr)
library(ggvis)
library(shinyURL)
library(shiny)

df <- read.csv("data/achievement_profile_data.csv", stringsAsFactors = FALSE)

# District characteristics for x variable
district_char <- c("Student Enrollment" = "Enrollment", 
                   "Percent Black Students" = "Pct_Black",
                   "Percent Hispanic Students" = "Pct_Hispanic",
                   "Percent Native American Students" = "Pct_Native_American",
                   "Percent English Learner Students" = "Pct_EL",
                   "Percent Economically Disadvantaged" = "Pct_ED",
                   "Percent Students with Disabilities" = "Pct_SWD",
                   "Per-Pupil Expenditures ($)" = "Per_Pupil_Expenditures",
                   "Percent Black/Hispanic/Native American Students" = "Pct_BHN",
                   "Percent Chronically Absent" = "Pct_Chronically_Absent", 
                   "Percent Suspended" = "Pct_Suspended",
                   "Percent Expelled" = "Pct_Expelled")

# Outcomes for y variable
district_out <- c("Math Percent Proficient or Advanced" = "Math",
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
                  "Percent Chronically Absent" = "Pct_Chronically_Absent", 
                  "Percent Suspended" = "Pct_Suspended",
                  "Percent Expelled" = "Pct_Expelled")

district_list <- c(" " = "State of Tennessee", df[2:nrow(df), ]$system_name)