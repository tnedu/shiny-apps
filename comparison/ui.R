## District Comparison Tool
# ui.R

shinyUI(navbarPage("Comparison Tool", theme = "doe-style.css",
    tabPanel("Identify Similar", icon = icon("search"),
        useShinyjs(),
        fluidRow(
            # Sidebar with input widgets
            column(3, offset = 1,
                wellPanel(
                    h4("Identify Similar Districts"),
                    br(),
                    selectInput(inputId = "district", label = "Select a District:",
                        choices = c("", sort(unique(ach_profile$District)))),
                    br(),
                    checkboxGroupInput(inputId = "chars",
                        label = "Select one or More District Characteristics:",
                        choices = c("Student Enrollment" = "Enrollment",
                            "Per-Pupil Expenditures" = "Expenditures",
                            "% Economically Disadvantaged" = "ED",
                            "% Students with Disabilities" = "SWD",
                            "% English Learner Students" = "EL",
                            "% Black Students" = "Black",
                            "% Hispanic Students" = "Hispanic",
                            "% Native American Students" = "Native"),
                        selected = c("Enrollment", "Black", "Hispanic", "Native", "EL", "ED", "SWD", "Expenditures")),
                    br(),
                    actionButton(inputId = "button", label = "Go!"),
                    hidden(tags$div(id = "info",
                        "Adjust any of the inputs in the left panels to update the output.")
                    )
                ),
                hidden(wellPanel(id = "outcomes",
                    selectInput(inputId = "outcome", label = "Select an outcome:",
                        choices = outcome_list, selected = "Algebra I"),
                    selectInput(inputId = "year", label = "School Year:",
                        choices = c("2015-16" = 2016, "2014-15" = 2015), selected = 2015)
                ))
            ),
            # Message shown on initializing
            conditionalPanel("input.button == 0",
                column(7,
                    h4("Using the input widgets on the left, select a school district and one or
                        more district characteristics."),
                    br(),
                    p("For the selected district, this tool will identify the most similar districts
                        based on the selected characteristics and display data for a selected outcome.")
                )
            ),
            conditionalPanel("input.button >= 1",
                # Message shown if no characteristics are selected
                hidden(tags$div(id = "request_input",
                    fluidRow(
                        h4("Please select a district and one or more district characteristics.")
                    )
                )),
                # Output panel
                tags$div(id = "output",
                    column(7,
                        h4(textOutput("header_plot")),
                        br(),
                        rbokehOutput("plot", height = "600px"),
                        br(),
                        h4(textOutput("header_table")),
                        br(),
                        tableOutput("table")
                    )
                )
            )
        )
    ),
    tabPanel("Select", icon = icon("hand-pointer-o"),
        fluidRow(
            column(3, offset = 1,
                wellPanel(
                    h4("Select Districts"),
                    br(),
                    selectInput(inputId = "district2", label = "Select a district:",
                        choices = sort(ach_profile$District)),
                    br(),
                    uiOutput("comparison_districts")
                ),
                wellPanel(
                    selectInput(inputId = "outcome2", label = "Select an outcome:",
                        choices = outcome_list, selected = "Math", width = 400),
                    br(),
                    selectInput(inputId = "year2", label = "School Year:",
                        choices = c("2015-16" = 2016, "2014-15" = 2015), selected = 2015)
                )
            ),
            column(7,
                rbokehOutput("plot2", height = "600px")
            )
        )
    )
))
