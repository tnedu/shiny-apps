library(tidyverse)
library(rgdal)
library(rbokeh)
library(leaflet)
library(shiny)

# District shapefile from NCES and filter out pseudo-districts
tennessee <- readOGR("SCHOOLDISTRICT_SY1314_TL15/schooldistrict_sy1314_tl15.shp") %>%
    subset(STATEFP == 47) %>%
    subset(!grepl(" in ", NAME)) %>%
    subset(!(NAME == "School District Not Defined")) %>%
    subset(!(NAME == "Fort Campbell Schools"))

# Sort by name so that merging happens correctly
tennessee <- tennessee[order(tennessee$NAME), ]

# Achievement/profile data
ach_profile <- read_csv("data/achievement_profile_data_2015_2016.csv") %>%
    mutate_each(funs(if_else(is.na(.), "NA", .)), starts_with("TVAAS"), `Accountability Status 2015`) %>%
    mutate_each(funs(if_else(is.na(.) & System != 970, 0, .)), Black, Hispanic, Native, EL)

# District characteristics for scatterplot
chars <- c("Student Enrollment" = "Enrollment",
           "Percent Economically Disadvantaged" = "ED",
           "Percent Black/Hispanic/Native American" = "BHN",
           "Percent Students with Disabilities" = "SWD",
           "Percent English Learners" = "EL",
           "Per-Pupil Expenditures" = "Expenditures")

# Outcomes for scatterplot
outcomes <- list(
    "TN Ready On Track/Mastery" = list("Math", "ELA", "Science",
                                       "Algebra I", "Algebra II", "Geometry",
                                       "English I", "English II", "English III",
                                       "Integrated Math I", "Integrated Math II", "Integrated Math III",
                                       "Biology I", "Chemistry", "US History"),
    "Absenteeism" = list("Chronic Absence"),
    "Discipline" = list("Suspension", "Expulsion"),
    "ACT" = list("ACT Composite", "ACT 21 or Above",
                 "ACT English", "ACT Math", "ACT Reading", "ACT Science"),
    "Graduation" = list("Grad", "Dropout"))

color_by <- c("Region",
              "TVAAS Composite",
              "TVAAS Literacy",
              "TVAAS Numeracy",
              "TVAAS Science",
              "TVAAS Social Studies",
              "Accountability Status 2015")

# Outcomes for map
outcomes_map <- list(
    "TN Ready On Track/Mastery" = list("Math", "ELA", "Science",
                                       "Algebra I", "Algebra II", "Geometry",
                                       "English I", "English II", "English III",
                                       "Integrated Math I", "Integrated Math II", "Integrated Math III",
                                       "Biology I", "Chemistry", "US History"),
    "Absenteeism" = list("Chronic Absence"),
    "Discipline" = list("Suspension", "Expulsion"),
    "ACT" = list("ACT Composite", "ACT 21 or Above",
                 "ACT English", "ACT Math", "ACT Reading", "ACT Science"),
    "Graduation" = list("Grad", "Dropout"),
    "TVAAS" = list("TVAAS Composite", "TVAAS Literacy", "TVAAS Numeracy",
                   "TVAAS Science", "TVAAS Social Studies"))
