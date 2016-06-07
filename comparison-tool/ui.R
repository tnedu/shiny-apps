## District Comparison Tool
# ui.R

shinyUI(navbarPage("Comparison Tool", position = "fixed-top",
                   
    tabPanel("District",
        fluidPage(
            br(),
            br(),
            br(),
            br(),
            fluidRow(
                column(3, offset = 1,
                    wellPanel(
                        strong("Select a school district and one or more district characteristics below."),
                        br(),
                        br(),
                        p("For the selected district, this tool will identify the most similar districts
                          based on the selected characteristics and display data for a selected outcome."),
                        br(),
                        selectInput("district", label = "Select a District:", choices = df_std$system_name),
                        br(),
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
                        br(),
                        actionButton("execute", "Go!")
                    )
                ),
                column(7,
                    ggvisOutput("plot"),
                    br(),
                    selectInput("outcome", label = "Select an Outcome:", choices = outcome_list)
                )
            ),
            br(),
            br(),
            br(),
            fluidRow(
                column(10, offset = 1,
                    hr(),
                    p("Designed by Alexander Poon in", tags$a(href = "http://shiny.rstudio.com/", "Shiny"), 
                      "for the Tennessee Department of Education.",
                      tags$a(href = "https://github.com/alexander-poon/shiny-apps/tree/master/data-explorer", "Source Code"), style = "font-size: 8pt")
                )
            )
        )
    )        
))