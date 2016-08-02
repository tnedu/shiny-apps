library(readr)
library(tidyr)
library(dplyr)
library(ReporteRs)
library(ggvis)
library(shiny)
library(shinyjs)

# Read in achievement and profile data, drop state observation
df <- read_csv("data/achievement_profile_data_with_CORE.csv") %>% 
    filter(system != 0)

# Read in historical data
historical <- read_csv("data/historical_data.csv") %>%
    rename("District" = system_name) %>%
    mutate(subject = ifelse(subject == "Algebra I", "AlgI", subject)) %>%
    mutate(subject = ifelse(subject == "Algebra II", "AlgII", subject)) %>%
    mutate(subject = ifelse(subject == "Biology I", "BioI", subject)) %>%
    mutate(subject = ifelse(subject == "English I", "EngI", subject)) %>%
    mutate(subject = ifelse(subject == "English II", "EngII", subject)) %>%
    mutate(subject = ifelse(subject == "English III", "EngIII", subject)) %>%
    mutate(subject = ifelse(subject == "RLA", "ELA", subject))

# District characteristics and outcomes in separate data frames, standardize characteristic variables
df_chars <- df %>%
    select(one_of(c("system_name", "Enrollment", "Pct_Black", "Pct_Hispanic", "Pct_Native_American", 
        "Pct_EL", "Pct_SWD", "Pct_ED", "Per_Pupil_Expenditures"))) %>%
    rename("Per-Pupil Expenditures" = Per_Pupil_Expenditures, "Percent Black" = Pct_Black,
        "Percent Hispanic" = Pct_Hispanic, "Percent Native American" = Pct_Native_American, 
        "Percent Economically Disadvantaged" = Pct_ED, "Percent Students with Disabilities" = Pct_SWD,
        "Percent English Learners" = Pct_EL)

df_std <- df %>%
    filter(complete.cases(df_chars)) %>%
    mutate_each_(funs(scale), vars = c("Enrollment", "Pct_Black", "Pct_Hispanic", "Pct_Native_American", 
        "Pct_EL", "Pct_SWD", "Pct_ED", "Per_Pupil_Expenditures")) %>%
    select(one_of(c("system_name", "Enrollment", "Pct_Black", "Pct_Hispanic", "Pct_Native_American", 
        "Pct_EL", "Pct_SWD", "Pct_ED", "Per_Pupil_Expenditures", "CORE_region")))

df_pctile <- df %>%
    filter(complete.cases(df_chars)) %>%
    mutate_each_(funs(percent_rank), vars = c("Enrollment", "Pct_Black", "Pct_Hispanic", "Pct_Native_American", 
        "Pct_EL", "Pct_SWD", "Pct_ED", "Per_Pupil_Expenditures")) %>%
    select(one_of(c("system_name", "Enrollment", "Pct_Black", "Pct_Hispanic", "Pct_Native_American", 
        "Pct_EL", "Pct_SWD", "Pct_ED", "Per_Pupil_Expenditures"))) %>%
    rename("District" = system_name, "Per-Pupil Expenditures" = Per_Pupil_Expenditures, "Percent Black" = Pct_Black,
        "Percent Hispanic" = Pct_Hispanic, "Percent Native American" = Pct_Native_American, 
        "Percent Economically Disadvantaged" = Pct_ED, "Percent Students with Disabilities" = Pct_SWD,
        "Percent English Learners" = Pct_EL)

df_outcomes <- df %>%
    filter(complete.cases(df_chars)) %>%
    select(one_of(c("system_name", "Math", "ELA", "Science", "AlgI", "AlgII", "BioI", "Chemistry",
        "EngI", "EngII", "EngIII", "Graduation", "Dropout", "ACT_Composite", "Pct_Chronically_Absent",
        "Pct_Suspended", "Pct_Expelled")))

# Calculate standard deviation of each characteristic variable
standard_devs <- df_chars %>%
    summarise("Enrollment" = sd(Enrollment, na.rm = TRUE),
        "Per-Pupil Expenditures" = sd(`Per-Pupil Expenditures`, na.rm = TRUE),
        "Percent Black" = sd(`Percent Black`, na.rm = TRUE),
        "Percent Hispanic" = sd(`Percent Hispanic`, na.rm = TRUE),
        "Percent Native American" = sd(`Percent Native American`, na.rm = TRUE),
        "Percent Economically Disadvantaged" = sd(`Percent Economically Disadvantaged`, na.rm = TRUE),
        "Percent Students with Disabilities" = sd(`Percent Students with Disabilities`, na.rm = TRUE),
        "Percent English Learners" = sd(`Percent English Learners`, na.rm = TRUE))

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
    "Graduation Rate" = "Graduation",
    "Dropout Rate" = "Dropout",
    "Average ACT Composite Score" = "ACT_Composite",
    "Chronic Absenteeism" = "Pct_Chronically_Absent",
    "Suspension Rate" = "Pct_Suspended",
    "Expulsion Rate" = "Pct_Expelled")
