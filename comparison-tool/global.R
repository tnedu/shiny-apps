library(tidyverse)
library(ReporteRs)
library(ggvis)
library(shiny)
library(shinyjs)

# Read in achievement and profile data, drop state observation
df <- read_csv("data/achievement_profile_data_with_CORE.csv") %>% 
    filter(system != 0)

# Read in historical data
historical <- read_csv("data/historical_data.csv") %>%
    mutate(subject = ifelse(subject == "Algebra I", "Alg I", subject),
        subject = ifelse(subject == "Algebra II", "Alg II", subject),
        subject = ifelse(subject == "Biology I", "Bio I", subject),
        subject = ifelse(subject == "English I", "Eng I", subject),
        subject = ifelse(subject == "English II", "Eng II", subject),
        subject = ifelse(subject == "English III", "Eng III", subject),
        subject = ifelse(subject == "RLA", "ELA", subject)) %>%
    spread(subject, pct_prof_adv, fill = NA) %>%
    gather(subject, pct_prof_adv, `Alg I`:Science, na.rm = FALSE)

# District characteristics and outcomes in separate data frames
df_chars <- df %>%
    select(District, Enrollment, Black, Hispanic, `Native American`, `English Learners`,
        `Students with Disabilities`, `Economically Disadvantaged`, `Per-Pupil Expenditures`) %>%
    rename(`Percent Black` = Black, `Percent Hispanic` = Hispanic, `Percent Native American` = `Native American`, 
        `Percent Economically Disadvantaged` = `Economically Disadvantaged`, 
        `Percent Students with Disabilities` = `Students with Disabilities`,
        `Percent English Learners` = `English Learners`)

df_outcomes <- df %>%
    filter(complete.cases(df_chars)) %>%
    select(District, `Alg I`:Science, `ACT Composite`:`Science Growth`)

# Standardize characteristic variables
df_std <- df %>%
    filter(complete.cases(df_chars)) %>%
    select(District, Enrollment:`Per-Pupil Expenditures`, Region) %>%
    mutate(Enrollment = scale(Enrollment),
        Black = scale(Black),
        Hispanic = scale(Hispanic),
        `Native American` = scale(`Native American`),
        `English Learners` = scale(`English Learners`),
        `Students with Disabilities` = scale(`Students with Disabilities`),
        `Economically Disadvantaged` = scale(`Economically Disadvantaged`),
        `Per-Pupil Expenditures` = scale(`Per-Pupil Expenditures`))

# Calculate standard deviation of each characteristic variable
standard_devs <- df_chars %>%
    summarise(`Enrollment` = sd(Enrollment, na.rm = TRUE),
        `Per-Pupil Expenditures` = sd(`Per-Pupil Expenditures`, na.rm = TRUE),
        `Percent Black` = sd(`Percent Black`, na.rm = TRUE),
        `Percent Hispanic` = sd(`Percent Hispanic`, na.rm = TRUE),
        `Percent Native American` = sd(`Percent Native American`, na.rm = TRUE),
        `Percent Economically Disadvantaged` = sd(`Percent Economically Disadvantaged`, na.rm = TRUE),
        `Percent Students with Disabilities` = sd(`Percent Students with Disabilities`, na.rm = TRUE),
        `Percent English Learners` = sd(`Percent English Learners`, na.rm = TRUE))

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
