library(tidyverse)
library(rbokeh)
library(shiny)
library(shinyjs)

ach_profile <- read_csv("data/achievement_profile_data_2015_2016.csv") %>%
    filter(District != "State of Tennessee") %>%
    mutate_each(funs(ifelse(is.na(.) & System != 970, 0, .)), Black, Hispanic, Native, EL)

# Outcome list for dropdown
outcome_list <- c("ACT Composite Average" = "ACT Composite",
    "ACT English Average" = "ACT English",
    "ACT Math Average" = "ACT Math",
    "ACT Reading Average" = "ACT Reading",
    "ACT Science Average" = "ACT Science",
    "Percent ACT Composite 21 or Above" = "ACT 21 or Above",
    "Math Percent Proficient/Advanced" = "Math",
    "ELA Percent Proficient/Advanced" = "ELA",
    "Science Percent Proficient/Advanced" = "Science",
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
