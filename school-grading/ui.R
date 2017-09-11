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

            # Priority (F) Schools
            hidden(div(id = "minimum_performance",
                hr(),
                h4("A success rate is the percentage of students on track or mastered
                    in math, English Language Arts, and science, aggregated across
                    subjects with at least 30 tests."),
                p("For high schools, this also includes students who earn an ACT Composite
                    score of 21 or higher."),
                br(),
                selectInput("success_3yr", label = "What is your school's one-year success rate or
                    two-year success rate if your school serves high school grades?",
                    choices = c("", "Less than 20%", "Between 20 and 35%", "Above 35%")),
                br(),
                hidden(selectInput("tvaas_lag", label = "Did your school earn a TVAAS Composite
                    Level 4 or 5 in 2017?", choices = c("", "Yes", "No"))),
                htmlOutput("priority_determination"),
                br(),
                hidden(actionButton("button_priority", label = "Got it."))
            )),

            # Achievement
            hidden(div(id = "achievement",
                hr(),
                h4("About your school's achievement and growth on TNReady:"),
                br(),
                p("Recall that a", strong("success rate"), "is the percentage of students on track
                    or mastered in math, ELA, and science (including ACT for high schools),
                    aggregated across subjects with at least 30 tests."),
                p(strong("Subgroup growth"), "refers to the percentage of students who
                    improved their performance level compared to the prior year."),
                p("A school's achievement score reflects", strong("the better of"),
                    "their success rates relative to the state of relative to their
                    AMO targets for both all students and subgroups."),
                br(),
                strong(p("Answer the following about your school's achievement and growth.")),
                rHandsontableOutput("achievement_table"),
                br(),
                div(id = "done_ach",
                    p("When you are done, click the button below."),
                    actionButton("button_achievement", label = "Done")
                )
            )),

            # Grad
            hidden(div(id = "grad",
                hr(),
                h4("About your school's Graduation Rate"),
                br(),
                selectInput("grad_eligible", label = "Does your school have a graduating
                    cohort of 30 or more students?", choices = c("", "Yes", "No")),
                br(),
                hidden(div(id = "grad_table_container",
                    p(strong("Graduation Rate"), "is the percent of students in the graduating
                        cohort who graduate in no more than four years plus a summer."),
                    br(),
                    strong(p("Answer the following about your school's graduation rate.")),
                    rHandsontableOutput("grad_table")
                )),
                hidden(actionButton("skip_grad", label = "Proceed")),
                br(),
                hidden(div(id = "done_grad",
                    p("When you are done, click the button below."),
                    actionButton("button_grad", label = "Done")
                ))
            )),

            # Readiness
            hidden(div(id = "readiness",
                hr(),
                h4("About your school's Ready Graduates"),
                br(),
                p(strong("Readiness"), "refers to the percentage of graduates who earned
                    an ACT Composite score of 21 or higher."),
                br(),
                strong(p("Answer the following about your school's readiness.")),
                rHandsontableOutput("readiness_table"),
                br(),
                div(id = "done_readiness",
                    p("When you are done, click the button below."),
                    actionButton("button_readiness", label = "Done")
                )
            )),

            # English Language Proficiency
            hidden(div(id = "elpa",
                hr(),
                h4("About your school's English Language Proficiency Assessment Results"),
                br(),
                selectInput("elpa_eligible", label = "Does your school have 10 or more students
                    who took an English Language Proficiency Assessment (ELPA)?",
                    choices = c("", "Yes", "No")),
                br(),
                hidden(div(id = "elpa_table_container",
                    p("Schools are graded on the percentage of students who meet the
                        growth standard on the English Language Proficiency Assessment."),
                    p("The growth standards are based on the performance of the students
                        in the prior year. They are as follows:"),
                    tableOutput("elpa_growth_standard"),
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
                    strong("Success Rate"), "and", strong("Success Rate Target"), "grades."),
                p("Your school's", strong("Growth Grade"), "is determined by",
                    strong("TVAAS"), "for All Students and", strong("Subgroup Growth"), "for subgroups."),
                p("Your school's", strong("Graduation Rate Grade"), "is the better of its",
                    strong("Graduation Rate"), "and", strong("Graduation Rate Target"), "grades."),
                p("Your school's", strong("Readiness Grade"), "is the better of its",
                    strong("Readiness"), "and", strong("Readiness Target"), "grades."),
                p("Your school's", strong("ELPA Grade"), "is determined by its",
                    strong("ELPA Growth Standard"), "grade."),
                p("Your school's", strong("Absenteeism Grade"), "is the better of its",
                    strong("Absenteeism"), "and", strong("Absenteeism Reduction Target"), "grades."),
                br(),
                p("For Achievement, Graduation Rate, Readiness, and Absenteeism, a school only
                    receives a grade if it has both the absolute and target components."),
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
            p("Created with", tags$a(href = "http://shiny.rstudio.com/", "Shiny"),
              "for the Tennessee Department of Education."),
            br(),
            br()
        )
    )
)
