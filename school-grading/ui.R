## School Grading Walkthrough
# ui.R

library(dplyr)
library(writexl)
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
                achievement, growth, and other indicators of school success.
                You may wish to consult", downloadLink("download_presentation", "this guide"),
                "as you work your way through the tool."),
            strong(p("We'll use your answers to project a grade under the new A-F
                school grading system. When you are ready, click the button below.")),
            br(),
            p("Note: This tool is for planning purposes only. Data thresholds
                and what it means to earn each letter grade on each indicator
                is subject to change."),
            br(),
            actionButton("button_intro", label = "Go!")
        ),

        # Priority (F) Schools
        hidden(div(id = "minimum_performance",
            hr(),
            h4("A success rate is the percentage of students on track or mastered in
                math, English language arts, and science, aggregated across subjects
                with at least 30 tests."),
            p("For high schools, this also includes students who earn an ACT composite
                score of 21 or higher."),
            br(),
            selectInput("success_3yr", label = "What is your school's one-year success rate or
                two-year success rate if your school serves high school grades?",
                choices = c("", "Less than 10%", "Between 10% and 15%", "Above 15%")),
            br(),
            hidden(selectInput("tvaas_lag", label = "Did your school earn a TVAAS Composite
                Level 4 or 5 in 2017?", choices = c("", "Yes", "No"))),
            htmlOutput("priority_determination"),
                br(),
                hidden(actionButton("button_priority", label = "Got it."))
            )),

        hidden(div(id = "tabs_panel",
            hr(),
            p("You will be presented with a series of tables corresponding to each school
                grading indicator. Please fill in the tables with the appropriate data
                in order to calculate a grade."),
            br(),
            tabsetPanel(id = "tabs",
                tabPanel("Achievement",
                    h4("About your school's achievement and growth on TNReady"),
                    br(),
                    p("Recall that a", strong("success rate"), "is the percentage of students on track
                        or mastered in math, ELA, and science (including ACT for high schools),
                        aggregated across subjects with at least 30 tests."),
                    br(),
                    strong(p("Answer the following about your school's achievement and growth.")),
                    rHandsontableOutput("achievement_table"),
                    br(),
                    div(id = "done_ach",
                        p("When you are done, click the button below."),
                        actionButton("button_ach", label = "Done")
                    )
                )
            )

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
            p("Your school's", strong("Growth Grade"), "is determined by its", strong("TVAAS"), "grades."),
            p("Your school's", strong("Graduation Rate Grade"), "is the better of its",
                strong("Graduation Rate"), "and", strong("Graduation Rate Target"), "grades."),
            p("Your school's", strong("Ready Graduates Grade"), "is the better of its",
                strong("Ready Graduates"), "and", strong("Ready Graduates Target"), "grades."),
            p("Your school's", strong("ELPA Grade"), "is determined by its",
                strong("ELPA Growth Standard"), "grade."),
            p("Your school's", strong("Absenteeism Grade"), "is the better of its",
                strong("Absenteeism"), "and", strong("Absenteeism Reduction Target"), "grades."),
            br(),
            hidden(div(id = "done_heatmap",
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
            # br(),
            # textOutput("priority_grad_warning"),
            # br(),
            # textOutput("focus_warning"),
            br(),
            p("Adjust any inputs to see how your school's grade is affected.")
            # downloadLink("download_data", "Click here"), "to download this data."
        )),

        # Footer
        hr(),
        p("© 2018 Tennessee Department of Education. Email", tags$a(href = "tned.accountability@tn.gov", "tned.accountability@tn.gov"),
            "with any questions."),
        br(),
        br()

        )
    )

)
