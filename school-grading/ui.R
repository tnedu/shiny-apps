## School Grading Walkthrough
# ui.R

library(dplyr)
library(shiny)
library(shinyjs)
library(rhandsontable)

fluidPage(theme = "doe-style.css",
    useShinyjs(),

    fluidRow(
        column(8, offset = 2,

            h2("School Grading Modeling"),

            # Introduction
            div(id = "intro",
                hr(),
                h4("We're going to ask a series of questions about your school's
                    achievement, growth, and other indicators of school success."),
                strong(p("We'll use your answers to project a grade under the new A-F
                    school grading system. When you are ready, click the button below.")),
                actionButton("button_intro", label = "Go!")
            ),

            # Comprehensive Support
            hidden(div(id = "minimum_performance",
                hr(),
                h4("A success rate is the percentage of students on track or mastered,
                    aggregated across subjects with at least 30 tests."),
                p("For high schools, this also includes students who earn a ACT Composite
                    score of 21 or higher."),
                br(),
                selectInput("success_3yr", label = "What is your school's three-year success rate?",
                    choices = c("", "Less than 20%", "Between 20% and 35%", "Above 35%")),
                br(),
                hidden(selectInput("tvaas_lag", label = "Did your school earn a TVAAS Composite
                    Level 4 or 5 in 2016?", choices = c("", "Yes", "No"))),
                htmlOutput("comprehensive_determination"),
                br(),
                hidden(actionButton("button_comprehensive", label = "Got it."))
            )),

            # Achievement
            hidden(div(id = "achievement",
                hr(),
                h4("About your school's achievement and growth on TNReady:"),
                br(),
                p("Recall that a", strong("success rate"), "is the percentage of students on track or
                    mastered, aggregated across subjects (including ACT) with at least 30 tests."),
                p("A success rate", strong("percentile"), "is the percentage of schools with a
                    success rate equal to or lower than that of your school. For instance, a
                    success rate at the 75th percentile means that your school performed on par
                    with or better than 75 percent of schools in the state."),
                p(strong("Subgroup growth"), "refers to the percentage of students who maintained
                    or improved their performance level compared to the prior year."),
                br(),
                strong(p("Answer the following about your school's achievement and growth.")),
                rHandsontableOutput("achievement_table"),
                br(),
                div(id = "done_ach",
                    p("When you are done, click the button below."),
                    actionButton("button_achievement", label = "Done")
                )
            )),

            # Readiness
            hidden(div(id = "readiness",
                hr(),
                h4("About your school's ACT and Graduation"),
                br(),
                selectInput("readiness_eligible", label = "Does your school have a graduating
                    cohort of 30 or more students?", choices = c("", "Yes", "No")),
                br(),
                hidden(div(id = "readiness_table_container",
                    p(strong("Readiness"), "refers to the percentage of students in your school's
                        graduating cohort who earned an ACT Composite score of 21 or higher."),
                    br(),
                    strong(p("Answer the following about your school's readiness.")),
                    rHandsontableOutput("readiness_table")
                )),
                hidden(actionButton("skip_readiness", label = "Proceed")),
                br(),
                hidden(div(id = "done_readiness",
                    p("When you are done, click the button below."),
                    actionButton("button_readiness", label = "Done")
                ))
            )),

            # English Language Proficiency
            hidden(div(id = "elpa",
                hr(),
                h4("About your school's English Language Proficiency"),
                br(),
                selectInput("elpa_eligible", label = "Does your school have 10 or more students
                    who took an English Language Proficiency Assessment (ELPA)?",
                    choices = c("", "Yes", "No")),
                br(),
                hidden(div(id = "elpa_table_container",
                    p("Schools are graded on the percentage of students who exit EL status or
                        meet the growth standard on the English Language Proficiency Assessment."),
                    br(),
                    strong(p("Answer the following about your school's ELPA performance.")),
                    rHandsontableOutput("elpa_table")
                )),
                hidden(actionButton("skip_elpa", label = "Proceed")),
                br(),
                hidden(div(id = "done_elpa",
                    p("When you are done, click the button below."),
                    actionButton("button_elpa", label = "Done")
                ))
            )),

            # Absenteeism
            hidden(div(id = "absenteeism",
                hr(),
                h4("About your school's chronic absenteeism"),
                br(),
                p(strong("Chronic absenteeism"), "refers to students who are absent for 10%
                    or more of a school year (18 days in a 180 day school year)."),
                br(),
                strong(p("Answer the following about your school's absenteeism.")),
                rHandsontableOutput("absenteeism_table"),
                br(),
                hidden(div(id = "done_absenteeism",
                    p("When you are done, click the button below."),
                    actionButton("button_absenteeism", label = "Done")
                ))
            )),

            # Heat map
            hidden(div(id = "heatmap",
                hr(),
                h4("Your School's Heat Map"),
                br(),
                tableOutput("heatmap"),
                br(),
                p("Your school's", strong("Achievement Grade"), "is the better of its",
                    strong("Success Rate Percentile"), "and", strong("Success Rate Target"), "grades."),
                p("Your school's", strong("Growth Grade"), "is determined by",
                    strong("TVAAS"), "for All Students and", strong("Subgroup Growth"), "for subgroups."),
                p("Your school's", strong("Readiness Grade"), "is the better of its",
                    strong("Readiness"), "and", strong("Readiness Target"), "grades."),
                p("Your school's", strong("ELPA Grade"), "is the better of its",
                    strong("ELPA Exit"), "and", strong("ELPA Growth Standard"), "grades."),
                p("Your school's", strong("Absenteeism Grade"), "is the better of its",
                    strong("Absenteeism"), "and", strong("Absenteeism Reduction Target"), "grades."),
                br(),
                p("For Achievement, Readiness, ELPA, and Absenteeism, a school only receives a grade
                    if it has both the absolute and target components."),
                hidden(div(id = "done_heatmap",
                    br(),
                    p("Click the button below to see your school's projected final grade."),
                    actionButton("button_heatmap", label = "Show Final Grade")
                ))
            )),

            # Determinations
            hidden(div(id = "determinations",
                hr(),
                h4("Your School's Final Grade"),
                br(),
                p("Based on the information you provided, we project the following grades:"),
                br(),
                tableOutput("final_grades"),
                br(),
                p("Adjust any inputs to see how your school's grade is affected.")
            )),

            # Footer
            hr(),
            p("Designed in", tags$a(href = "http://shiny.rstudio.com/", "Shiny"),
              "for the Tennessee Department of Education."),
            br(),
            br()
        )
    )
)
