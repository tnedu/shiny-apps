library(tidyverse)
library(ggvis)
library(shiny)

enableBookmarking(store = "url")

df <- read_csv("data/achievement_profile_data_with_CORE.csv") %>%
    rename(Region = CORE_region) %>%
    mutate(Region = sub(" CORE", "", Region),
        system_name = sub("Special School District", "SSD", system_name),
        Enrollment = ifelse(system_name == "State of Tennessee", NA, Enrollment))

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

# District list for highlighting
district_list <- c(" " = "State of Tennessee", df[-1, ]$system_name)

# Ranges for slider
ranges <- df %>%
    select(Enrollment:Dropout) %>%
    gather(Characteristic, Value, Enrollment:Dropout) %>%
    group_by(Characteristic) %>%
    summarise(Min = min(Value, na.rm = TRUE), Max = max(Value, na.rm = TRUE))
