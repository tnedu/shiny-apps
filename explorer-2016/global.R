library(tidyverse)
library(leaflet)
library(rbokeh)
library(shiny)

ach_profile <- read_csv("data/achievement_profile_data_2015_2016.csv") %>%
    mutate(`TVAAS Composite` = ifelse(is.na(`TVAAS Composite`), "NA", `TVAAS Composite`),
           `TVAAS Literacy` = ifelse(is.na(`TVAAS Literacy`), "NA", `TVAAS Literacy`),
           `TVAAS Numeracy` = ifelse(is.na(`TVAAS Numeracy`), "NA", `TVAAS Numeracy`),
           `TVAAS Science` = ifelse(is.na(`TVAAS Science`), "NA", `TVAAS Science`),
           `TVAAS Social Studies` = ifelse(is.na(`TVAAS Social Studies`), "NA", `TVAAS Social Studies`),
           `Accountability Status 2015` = ifelse(is.na(`Accountability Status 2015`), "NA", `Accountability Status 2015`))

geocode <- read_csv("data/district_location_geocode.csv") %>%
    mutate(City = paste0(City, ", ", State, " ", Zip))

district_char <- c("Student Enrollment" = "Enrollment",
                   "Percent Economically Disadvantaged" = "ED",
                   "Percent Black/Hispanic/Native American" = "BHN",
                   "Percent Students with Disabilities" = "SWD",
                   "Percent English Learners" = "EL",
                   "Per-Pupil Expenditures" = "Expenditures")

district_out <- c("ACT Composite Average" = "ACT Composite",
                  "ACT English Average" = "ACT English",
                  "ACT Math Average" = "ACT Math",
                  "ACT Reading Average" = "ACT Reading",
                  "ACT Science Average" = "ACT Science",
                  "ACT Composite" = "ACT 21 or Above",
                  "Math Percent On Track/Mastered" = "Math",
                  "ELA Percent On Track/Mastered" = "ELA",
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

district_color <- c("Region",
                    "TVAAS Composite",
                    "TVAAS Literacy",
                    "TVAAS Numeracy",
                    "TVAAS Science",
                    "TVAAS Social Studies",
                    "Accountability Status 2015")
