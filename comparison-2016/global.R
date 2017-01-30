library(tidyverse)
library(rbokeh)
library(shiny)
library(shinyjs)

ach_profile <- read_csv("data/achievement_profile_data_2015_2016.csv") %>%
    filter(District != "State of Tennessee") %>%
    filter(Year == 2016)

# District characteristics and outcomes in separate data frames
chars <- ach_profile %>%
    select(Year, District, Enrollment, Black, Hispanic, Native, ED, SWD, EL, Expenditures) %>%
    rename(`Percent Black` = Black,
        `Percent Hispanic` = Hispanic,
        `Percent Native American` = Native,
        `Percent Economically Disadvantaged` = ED,
        `Percent Students with Disabilities` = SWD,
        `Percent English Learners` = EL)

outcomes <- ach_profile %>%
    # filter(complete.cases(chars)) %>%
    select(District, ELA:`US History`, `ACT English`:`ACT 21 or Above`,
           `Chronic Absence`, Suspension, Expulsion, Grad, Dropout)

# Standardize characteristic variables
chars_std <- ach_profile %>%
    filter(complete.cases(chars)) %>%
    select(Year, District, Enrollment:Expenditures, Region) %>%
    mutate_each(funs(scale(.)), Enrollment:Expenditures)

# Outcomes
outcome_list <- c("ACT Composite Average" = "ACT Composite",
    "ACT English Average" = "ACT English",
    "ACT Math Average" = "ACT Math",
    "ACT Reading Average" = "ACT Reading",
    "ACT Science Average" = "ACT Science",
    "ACT Composite" = "ACT 21 or Above",
    "Math Percent Proficient/Advanced" = "Math",
    "ELA Percent Proficient/Advanced" = "ELA",
    "Science Percent On Track/Mastered" = "Science",
    "Algebra I Percent On Track/Mastered" = "Algebra I",
    "Algebra II Percent On Track/Mastered" = "Algebra II",
    "Biology I Percent Proficient/Advanced" = "Biology I",
    "Chemistry Percent Proficient/Advanced" = "Chemistry",
    "English I Percent On Track/Mastered" = "English I",
    "English II Percent On Track/Mastered" = "English II",
    "English III Percent On Track/Mastered" = "English III",
    "Geometry Percent On Track/Mastered" = "Geometry",
    "Integrated Math I Percent On Track/Mastered" = "Integrated Math I",
    "Integrated Math II Percent On Track/Mastered" = "Integrated Math II",
    "Integrated Math III Percent On Track/Mastered" = "Integrated Math III",
    "US History Percent On Track/Mastered" = "US History",
    "Graduation Rate" = "Grad",
    "Dropout Rate" = "Dropout")
