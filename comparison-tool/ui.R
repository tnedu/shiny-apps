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
                        strong(p("Select a school district and one or more district characteristics below.")),
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
                                           selected = c("Enrollment", "Pct_EL", "Pct_ED", "Pct_SWD", "Per_Pupil_Expenditures")
                        ),
                        br(),
                        selectInput("outcome", label = "Select an outcome to plot:", choices = outcome_list, selected = "Math", width = 400)
                    )
                ),
                column(7,
                    h4(textOutput("header")),
                    br(),
                    ggvisOutput("plot_prof"),
                    br()
                )
            ),
            fluidRow(
                column(7, offset = 4,
                    h4(textOutput("header2")),
                    br(),
                    tableOutput("table"),
                    br(),
                    tags$b("Click on any bar to compare district profile data."),
                    br(),
                    "Differences of more than half and a full a standard deviation are highlighted in yellow and orange, respectively."
                )
            ),
            fluidRow(
                column(10, offset = 1,
                    hr(),
                    p("Designed by", tags$a(href = "mailto:alex.poon@tn.gov", "Alexander Poon"), 
                      "in", tags$a(href = "http://shiny.rstudio.com/", "Shiny"), "for the Tennessee Department of Education.",
                      tags$a(href = "https://github.com/alexander-poon/shiny-apps/tree/master/data-explorer", "Source Code"), style = "font-size: 8pt"),
                    br(),
                    br()
                )
            )
        )
    )        
))