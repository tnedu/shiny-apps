library(readr)
library(tidyr)
library(dplyr)
library(ggvis)
library(formattable)
library(ReporteRs)
library(shinydashboard)

# District characteristics for data explorer
district_char <- c("Student Enrollment" = "Enrollment", 
                   "Percent Black Students" = "Pct_Black",
                   "Percent Hispanic Students" = "Pct_Hispanic",
                   "Percent Native American Students" = "Pct_Native_American",
                   "Percent English Learner Students" = "Pct_EL",
                   "Percent Economically Disadvantaged" = "Pct_ED",
                   "Percent Students with Disabilities" = "Pct_SWD",
                   "Per-Pupil Expenditures ($)" = "Per_Pupil_Expenditures",
                   "Percent Black/Hispanic/Native American Students" = "Pct_BHN",
                   "Chronic Absenteeism Rate" = "Pct_Chronically_Absent", 
                   "Suspension Rate" = "Pct_Suspended",
                   "Expulsion Rate" = "Pct_Expelled")

# District outcomes for data explorer, comparison tool
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

# System numeric for profile tab
system_numeric <- read_csv("data/system_numeric_with_super_subgroup.csv") %>%
    mutate(subject = ifelse(subject == "ELA" & grade == "3rd through 5th", "3-5 ELA", subject)) %>%
    mutate(subject = ifelse(subject == "ELA" & grade == "6th through 8th", "6-8 ELA", subject)) %>%
    mutate(subject = ifelse(subject == "Math" & grade == "3rd through 5th", "3-5 Math", subject)) %>%
    mutate(subject = ifelse(subject == "Math" & grade == "6th through 8th", "6-8 Math", subject))

numeric_proficiency <- system_numeric %>%
    filter(subject != "ACT Composite" & subject != "Graduation Rate") %>%
    select(one_of(c("system_name", "subject", "subgroup", "pct_prof_adv"))) %>%
    spread("subject", "pct_prof_adv")

# Accountability heat maps
participation <- read_csv("data/participation_master.csv")

performance_gate <- read_csv("data/performance_gate_master.csv")

achievement <- read_csv("data/achievement_master.csv") %>%
    mutate(subject = ifelse(subject == "ELA" & grade == "3rd through 5th", "3-5 ELA", subject)) %>%
    mutate(subject = ifelse(subject == "ELA" & grade == "6th through 8th", "6-8 ELA", subject)) %>%
    mutate(subject = ifelse(subject == "Math" & grade == "3rd through 5th", "3-5 Math", subject)) %>%
    mutate(subject = ifelse(subject == "Math" & grade == "6th through 8th", "6-8 Math", subject))


gap_closure <- read_csv("data/gap_closure_master.csv") %>%
    mutate(subject = ifelse(subject == "ELA" & grade == "3rd through 5th", "3-5 ELA", subject)) %>%
    mutate(subject = ifelse(subject == "ELA" & grade == "6th through 8th", "6-8 ELA", subject)) %>%
    mutate(subject = ifelse(subject == "Math" & grade == "3rd through 5th", "3-5 Math", subject)) %>%
    mutate(subject = ifelse(subject == "Math" & grade == "6th through 8th", "6-8 Math", subject))

determinations <- read_csv("data/final_determinations.csv") %>%
    select(one_of(c("system_name", "minimum_performance_goal", "achievement_determination", 
                    "gap_determination", "final_determination"))) %>%
    mutate(minimum_performance_goal = ifelse(is.na(minimum_performance_goal), "N/A", minimum_performance_goal)) %>%
    mutate(achievement_determination = ifelse(is.na(achievement_determination), "N/A", achievement_determination)) %>%
    mutate(gap_determination = ifelse(is.na(gap_determination), "N/A", gap_determination)) %>%
    mutate(final_determination = ifelse(is.na(final_determination), "N/A", final_determination))

district_list <- unique(determinations$system_name)

color_list <- c("Met" = "blue",
                "Missed" = "red",
                "N/A" = "black",
                "In Need of Improvement" = "red",
                "Progressing" = "yellow",
                "Achieving" = "green",
                "Exemplary" = "blue")

# District achievement, profile data for comparison tool
ach_profile <- read.csv("data/achievement_profile_data.csv", stringsAsFactors = FALSE)

profile_std <- ach_profile %>%
    filter(system != 0) %>%
    mutate_each_(funs(scale), vars = c("Enrollment", "Pct_Black", "Pct_Hispanic", "Pct_Native_American", 
                                       "Pct_EL", "Pct_SWD", "Pct_ED", "Per_Pupil_Expenditures")) %>%
    select(one_of(c("system_name", "Enrollment", "Pct_Black", "Pct_Hispanic", "Pct_Native_American", 
                    "Pct_EL", "Pct_SWD", "Pct_ED", "Per_Pupil_Expenditures")))

df_profile <- ach_profile %>%
    select(one_of(c("system_name", "Enrollment", "Pct_Black", "Pct_Hispanic", "Pct_Native_American", 
                    "Pct_EL", "Pct_SWD", "Pct_ED", "Per_Pupil_Expenditures")))

df_outcomes <- ach_profile %>%
    select(one_of(c("system_name", "Math", "ELA", "Science", "AlgI", "AlgII", "BioI", "Chemistry",
                    "EngI", "EngII", "EngIII", "Graduation", "Dropout", "ACT_Composite",
                    "Pct_Chronically_Absent", "Pct_Suspended", "Pct_Expelled")))