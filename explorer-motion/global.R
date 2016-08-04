library(readr)
library(dplyr)
library(googleVis)
library(shiny)

ach_profile <- read_csv("data/achievement_profile_data_with_CORE.csv") %>%
    select(-system) %>%
    mutate(Year = 2015) %>%
    rename(District = system_name,
        `Algebra I Percent Proficient or Advanced` = AlgI,
        `Algebra II Percent Proficient or Advanced` = AlgII,
        `Biology I Percent Proficient or Advanced` = BioI,
        `Chemistry Percent Proficient or Advanced` = Chemistry,
        `ELA Percent Proficient or Advanced` = ELA,
        `English I Percent Proficient or Advanced` = EngI,
        `English II Percent Proficient or Advanced` = EngII,
        `English III Percent Proficient or Advanced` = EngIII,
        `Math Percent Proficient or Advanced` = Math,
        `Science Percent Proficient or Advanced` = Science,
        `Student Enrollment` = Enrollment,
        `Percent Black Students` = Pct_Black,
        `Percent Hispanic Students` = Pct_Hispanic,
        `Percent Native American Students` = Pct_Native_American,
        `Percent English Learners` = Pct_EL,
        `Percent Students with Disabilities` = Pct_SWD,
        `Percent Economically Disadvantaged` = Pct_ED,
        `Per-Pupil Expenditures` = Per_Pupil_Expenditures,
        `Percent Black/Hispanic/Native American Students` = Pct_BHN,
        `Average ACT Composite Score` = ACT_Composite,
        `Chronic Absenteeism` = Pct_Chronically_Absent,
        `Suspension Rate` = Pct_Suspended,
        `Expulsion Rate` = Pct_Expelled,
        `Graduation Rate` = Graduation,
        `Dropout Rate` = Dropout,
        `CORE Region` = CORE_region)
