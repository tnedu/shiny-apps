library(tidyverse)
library(ReporteRs)
library(ggvis)
library(shiny)
library(shinyjs)

# Read in achievement and profile data, drop state observation
ach_profile <- read_csv("data/achievement_profile_data_with_CORE.csv") %>%
    filter(system != 0)

# Read in historical data
historical <- read_csv("data/historical_data.csv")

# District characteristics and outcomes in separate data frames
chars <- ach_profile %>%
    select(District, Enrollment:`Per-Pupil Expenditures`) %>%
    rename(`Percent Black` = Black, `Percent Hispanic` = Hispanic, 
        `Percent Native American` = `Native American`, 
        `Percent Economically Disadvantaged` = `Economically Disadvantaged`, 
        `Percent Students with Disabilities` = `Students with Disabilities`,
        `Percent English Learners` = `English Learners`)

outcomes <- ach_profile %>%
    filter(complete.cases(chars)) %>%
    select(District, `Algebra I`:Science, `ACT Composite`:`Science Growth`)

# Standardize characteristic variables
chars_std <- ach_profile %>%
    filter(complete.cases(chars)) %>%
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
standard_devs <- chars %>%
    summarise(`Enrollment` = sd(Enrollment, na.rm = TRUE),
        `Per-Pupil Expenditures` = sd(`Per-Pupil Expenditures`, na.rm = TRUE),
        `Percent Black` = sd(`Percent Black`, na.rm = TRUE),
        `Percent Hispanic` = sd(`Percent Hispanic`, na.rm = TRUE),
        `Percent Native American` = sd(`Percent Native American`, na.rm = TRUE),
        `Percent Economically Disadvantaged` = sd(`Percent Economically Disadvantaged`, na.rm = TRUE),
        `Percent Students with Disabilities` = sd(`Percent Students with Disabilities`, na.rm = TRUE),
        `Percent English Learners` = sd(`Percent English Learners`, na.rm = TRUE))

# Outcome vector
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
    "Graduation Rate" = "Graduation Rate",
    "Dropout Rate" = "Dropout Rate",
    "Chronic Absence Rate" = "Chronic Absence",
    "Suspension Rate" = "Suspension Rate",
    "Expulsion Rate" = "Expulsion Rate")
