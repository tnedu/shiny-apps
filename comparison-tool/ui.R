## District Comparison Tool
# ui.R

shinyUI(navbarPage("Comparison Tool", position = "fixed-top",
                   
    tabPanel("District",
        fluidPage(
            br(),
            br(),
            br(),
            fluidRow(
                column(3, offset = 1,
                wellPanel(
                
                strong(p("Select a district and one or more district characteristics below.")),
                p("For the selected district, this application will identify the 8 most similar districts
                  based on the characteristics selected and display data for the selected outcome"),
                tags$br(),    
                selectInput("district", label = "Select a District:", choices = df_std$system_name),
                tags$br(),
                checkboxGroupInput("district_chars", 
                                   label = "Select One or More District Characteristics:",
                                   choices = c("Student Enrollment" = "Enrollment", 
                                               "% Black Students" = "Pct_Black",
                                               "% Hispanic Students" = "Pct_Hispanic",
                                               "% Native American Students" = "Pct_Native_American",
                                               "% English Learner Students" = "Pct_EL",
                                               "% Economically Disadvantaged" = "Pct_ED",
                                               "% Students with Disabilities" = "Pct_SWD",
                                               "Per-Pupil Expenditures" = "Per_Pupil_Expenditures"),
                                   selected = c("Enrollment", "Pct_EL", "Pct_ED", "Pct_SWD", 
                                                "Per_Pupil_Expenditures")
                                   ),
                selectInput("subject", label = "Select a Subject:", choices = subject_list)
                )
                ),
                column(7,
                    ggvisOutput("plot")
                
                )
            )
        )
    )        
))