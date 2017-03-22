library(tidyverse)
library(leaflet)
library(rbokeh)
library(shiny)

ach_profile <- read_csv("data/achievement_profile_data_2015_2016.csv") %>%
    mutate_each(funs(ifelse(is.na(.), "NA", .)), starts_with("TVAAS"), `Accountability Status 2015`) %>%
    mutate_each(funs(ifelse(is.na(.) & System != 970, 0, .)), Black, Hispanic, Native, EL)

geocode <- read_csv("data/district_location_geocode.csv") %>%
    mutate(City = paste0(City, ", ", State, " ", Zip))

chars <- c("Student Enrollment" = "Enrollment",
    "Percent Economically Disadvantaged" = "ED",
    "Percent Black/Hispanic/Native American" = "BHN",
    "Percent Students with Disabilities" = "SWD",
    "Percent English Learners" = "EL",
    "Per-Pupil Expenditures" = "Expenditures")

outcomes <- c("ACT Composite Average" = "ACT Composite",
    "ACT English Average" = "ACT English",
    "ACT Math Average" = "ACT Math",
    "ACT Reading Average" = "ACT Reading",
    "ACT Science Average" = "ACT Science",
    "ACT Composite" = "ACT 21 or Above",
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

color_by <- c("Region",
    "TVAAS Composite",
    "TVAAS Literacy",
    "TVAAS Numeracy",
    "TVAAS Science",
    "TVAAS Social Studies",
    "Accountability Status 2015")
