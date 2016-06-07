library(shiny)
library(dplyr)
library(ggvis)

df <- read.csv("data/achievement_profile_data.csv", stringsAsFactors = FALSE)

# Drop State observation, standardize characteristic variables
df_std <- df %>%
    filter(system != 0) %>%
    mutate_each_(funs(scale), vars = c("Enrollment", "Pct_Black", "Pct_Hispanic", "Pct_Native_American", 
                                       "Pct_EL", "Pct_SWD", "Pct_ED", "Per_Pupil_Expenditures", "Pct_BHN"))

df_achievement <- df %>%
    select(one_of(c("system_name", "Math", "ELA", "Science",
                    "AlgI", "AlgII", "BioI", "Chemistry", "EngI", "EngII", "EngIII")))

# Subject vector for select input
subject_list <- c("Math" = "Math",
                  "English Language Arts" = "ELA",
                  "Science" = "Science",
                  "Algebra I" = "AlgI",
                  "Algebra II" = "AlgII",
                  "Biology I" = "BioI",
                  "Chemistry" = "Chemistry",
                  "English I" = "EngI",
                  "English II" = "EngII",
                  "English III" = "EngIII")