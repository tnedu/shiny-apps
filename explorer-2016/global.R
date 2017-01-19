library(tidyverse)
library(leaflet)
library(rbokeh)
library(shiny)

ach_profile <- read_csv("data/achievement_profile_data_2015_2016.csv") %>%
    mutate(`TVAAS Composite` = paste("Level", `TVAAS Composite`),
           `TVAAS Literacy` = paste("Level", `TVAAS Literacy`),
           `TVAAS Numeracy` = paste("Level", `TVAAS Numeracy`),
           `TVAAS Science` = paste("Level", `TVAAS Science`),
           `TVAAS Social Studies` = paste("Level", `TVAAS Social Studies`),
           `Accountability 2015` = ifelse(is.na(`Accountability 2015`), "NA", `Accountability 2015`))

geocode <- read_csv("data/district_location_geocode.csv")

district_char <- c("Enrollment",
                   "ED",
                   "BHN",
                   "SWD",
                   "EL",
                   "Expenditures")

district_out <- c("ACT Composite",
                  "ACT English",
                  "ACT Math",
                  "ACT Reading",
                  "ACT Science",
                  "ACT 21 or Above",
                  "Math",
                  "ELA",
                  "Science",
                  "Algebra I",
                  "Algebra II",
                  "Biology I",
                  "Chemistry",
                  "English I",
                  "English II",
                  "English III",
                  "Geometry",
                  "Integrated Math I",
                  "Integrated Math II",
                  "Integrated Math III",
                  "US History",
                  "Grad",
                  "Dropout")

district_color <- c("Region",
                    "TVAAS Composite",
                    "TVAAS Literacy",
                    "TVAAS Numeracy",
                    "TVAAS Science",
                    "TVAAS Social Studies",
                    "Accountability 2015")
