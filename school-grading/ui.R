## School Grading Walkthrough
# ui.R

library(dplyr)
library(shiny)
library(shinyjs)
library(rhandsontable)

shinyUI(
    fluidPage(
        useShinyjs(),
        fluidRow(
            column(8, offset = 2,

                # Introduction
                div(id = "intro",
                    br(),
                    h4("We're going to ask a series of questions about your school's academic
                        achievement, growth, and other indicators of school success."),
                    strong(p("We'll use your answers to project a grade under the new A-F
                        school grading system. When you are ready, click the button below.")),
                    actionButton("button_intro", label = "Go!")
                ),

                # Pool
                hidden(div(id = "pool",
                    hr(),
                    h4("First, we'll determine your school's grade pool for accountability purposes."),
                    br(),
                    selectInput("eoc", label = "Will your school have 30 students in grades 9 or above
                        test in a single high school End of Course subject this school year?",
                        choices = c("", "Yes", "No")),
                    br(),
                    htmlOutput("pool_determination"),
                    br(),
                    hidden(actionButton("button_pool", label = "Got it."))
                )),

                # Comprehensive Support
                hidden(div(id = "minimum_performance",
                    hr(),
                    h4("A success rate is the percentage of students on track or mastered,
                        aggregated across subjects with at least 30 tests."),
                    p("For high schools, this also includes the percentage of students who
                        earned an 21 Composite score or higher on the ACT and students
                        who earn graduate in four years and a summer."),
                    selectInput("success_3yr", label = "Think about your school's success rate over
                        the last three years. What is your school's success rate?",
                        choices = c("", "Less than 20%", "Between 20% and 35%", "Above 35%")),
                    br(),
                    hidden(selectInput("tvaas_lag", label = "Did your school earn a TVAAS Composite
                        Level 4 or 5 in 2016?", choices = c("", "Yes", "No"))),
                    br(),
                    htmlOutput("comprehensive_determination"),
                    br(),
                    hidden(actionButton("button_comprehensive", label = "Got it."))
                )),

                # Achievement
                hidden(div(id = "achievement",
                    hr(),
                    h4("About your school's achievement and growth on TNReady:"),
                    strong(p("Using the table below, answer the following about your school's success rate,
                        success rate growth, TVAAS (All Students only), and subgroup growth
                        (subgroups only).")),
                    p("Recall that a", strong("success rate"), "is the percentage of students on track
                        or mastered, aggregated across all subjects with at least 30 tests."),
                    p("A success rate", strong("percentile"), "is the percentage of schools with a
                        success rate equal to or lower than that of your school. For instance, a
                        success rate at the 75th percentile means that your school performed on par
                        with or better than 75 percent of schools in the state."),
                    p(strong("Subgroup growth"), "refers to the percentage of students who maintained
                        or improved their performance level compared to the prior year."),
                    br(),
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
                            graduating cohort who earned an 21 Composite score or higher on the ACT.
                            Answer the following about your school's readiness."),
                        br(),
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
                            met the growth standard on the English Language Proficiency Assessment.
                            Answer the following about your school's ELPA performance."),
                        br(),
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
                    p(strong("Chronic absenteeism"), "refers to the percentage of students who are
                        absent for 10% or more of a school year (18 days in a 180 day school year).
                        Answer the following about your school's chronic absenteeism."),
                    br(),
                    rHandsontableOutput("absenteeism_table"),
                    br(),
                    hidden(div(id = "done_absenteeism",
                        p("When you are done, click the button below."),
                        actionButton("button_absenteeism", label = "Done")
                    ))
                ))

            )
        ),

        # Heat map
        hidden(div(id = "heatmap",
            fluidRow(
                column(8, offset = 2,
                    hr(),
                    h4("Your School's Heat Map"),
                    br(),
                    tableOutput("heat_map")
                )
            )
        )),

        # Determinations
        hidden(div(id = "determinations",
            fluidRow(
                column(8, offset = 2,
                    hr(),
                    h4("Your School's Final Grade"),
                    p("Based on the information you provided, we project the following grades for
                        your school:"),
                    br(),
                    strong(p(htmlOutput("determinations"))),
                    br(),
                    p("Adjust any of the values in the above tables to see how your school's
                        grade is affected.")
                )
            )
        )),

        fluidRow(
            column(8, offset = 2,
                hr(),
                p("Designed in", tags$a(href = "http://shiny.rstudio.com/", "Shiny"),
                    "for the Tennessee Department of Education."),
                br(),
                br()
            )
        )
    )
)
