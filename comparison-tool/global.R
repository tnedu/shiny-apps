library(shiny)
library(dplyr)
library(ggvis)

df <- read.csv("data/achievement_profile_data.csv", stringsAsFactors = FALSE)

df[is.na(df$Pct_Chronically_Absent), ]$Pct_Chronically_Absent <- 0
df[is.na(df$ACT_composite), ]$ACT_composite <- 0

# Drop State observation, standardize characteristic variables
df_std <- df %>%
    filter(system != 0) %>%
    mutate_each_(funs(scale), vars = c("Enrollment", "Pct_Black", "Pct_Hispanic", "Pct_Native_American", 
                                       "Pct_EL", "Pct_SWD", "Pct_ED", "Per_Pupil_Expenditures", "Pct_BHN")) %>%
    select(one_of(c("system_name", "Enrollment", "Pct_Black", "Pct_Hispanic", "Pct_Native_American", 
                    "Pct_EL", "Pct_SWD", "Pct_ED", "Per_Pupil_Expenditures", "Pct_BHN")))

df_outcomes <- df %>%
    select(one_of(c("system_name", "Math", "ELA", "Science", "AlgI", "AlgII", "BioI", "Chemistry",
                    "EngI", "EngII", "EngIII", "ACT_composite", "Pct_Chronically_Absent", "Pct_Suspended", "Pct_Expelled")))

# Outcome vector for select input
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
                  "Average ACT Composite Score" = "ACT_composite",
                  "Chronic Absenteeism" = "Pct_Chronically_Absent",
                  "Suspension Rate" = "Pct_Suspended",
                  "Expulsion Rate" = "Pct_Expelled")