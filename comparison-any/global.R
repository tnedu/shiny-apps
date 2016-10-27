library(tidyverse)
library(shiny)
library(ggvis)

ach_profile <- read_csv("data/achievement_profile_data_with_CORE.csv")

historical <- read_csv("data/historical_data.csv") %>%
    mutate(subject = ifelse(subject == "Algebra I", "Alg I", subject),
        subject = ifelse(subject == "Algebra II", "Alg II", subject),
        subject = ifelse(subject == "Biology I", "Bio I", subject),
        subject = ifelse(subject == "English I", "Eng I", subject),
        subject = ifelse(subject == "English II", "Eng II", subject),
        subject = ifelse(subject == "English III", "Eng III", subject),
        subject = ifelse(subject == "RLA", "ELA", subject)) %>%
    spread(subject, pct_prof_adv) %>%
    gather(subject, pct_prof_adv, `Alg I`:Science, na.rm = FALSE)

# Outcome vector for select input
outcome_list <- c("Math Percent Proficient or Advanced" = "Math",
    "English Language Arts Percent Proficient or Advanced" = "ELA",
    "Science Percent Proficient or Advanced" = "Science",
    "Algebra I Percent Proficient or Advanced" = "Alg I",
    "Algebra II Percent Proficient or Advanced" = "Alg II",
    "Biology I Percent Proficient or Advanced" = "Bio I",
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
    "Graduation Rate" = "Graduation",
    "Dropout Rate" = "Dropout",
    "Average ACT Composite Score" = "ACT Composite",
    "Chronic Absence" = "Chronic Absence",
    "Suspension Rate" = "Suspension Rate",
    "Expulsion Rate" = "Expulsion Rate")
