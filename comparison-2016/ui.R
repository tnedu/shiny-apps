## District Comparison Tool
# ui.R

shinyUI(navbarPage("Comparison Tool",

    tabPanel("District",
        useShinyjs(),
        fluidRow(
            column(3, offset = 1,
                wellPanel(
                    h4("Identify Similar Districts"),
                    br(),
                    selectInput(inputId = "district", label = "Select a District:",
                        choices = sort(unique(chars_std$District))),
                    br(),
                    checkboxGroupInput(inputId = "district_chars",
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
                conditionalPanel(condition = "input.button >= 1",
                    wellPanel(
                        h4("Outcome to Plot"),
                        br(),
                        selectInput(inputId = "outcome", label = "Outcome to plot:",
                            choices = outcome_list, selected = "Algebra I")
                        # selectInput(inputId = "year", label = "School Year",
                        #     choices = c("2014-15" = 2015, "2015-16" = 2016), selected = 2016)
                    ),
                    wellPanel(
                        h4("Additional Options"),
                        br(),
                        sliderInput(inputId = "num_districts", label = "Number of comparison districts:", min = 1, max = 9, value = 5, step = 1, ticks = FALSE),
                        br(),
                        tags$b("Restrict comparison districts to the same:"),
                        checkboxInput(inputId = "restrict_CORE", label = "CORE Region", value = FALSE)
                    )
                )
            ),
            # Message to be shown on initializing
            conditionalPanel("input.button == 0",
                column(7,
                    h4("Using the input widgets on the left, select a school district and one or more district characteristics."),
                    br(),
                    p("For the selected district, this tool will identify the most similar districts based on the selected
                      characteristics and display data for a selected outcome.")
                )
            ),
            conditionalPanel(condition = "input.button >= 1",
                # Message to be shown if no characteristics are selected
                hidden(tags$div(id = "request_input",
                    fluidRow(
                        h4("Please select one or more district characteristics.")
                    )
                )),
                tags$div(id = "output",
                    column(7,
                        h4(textOutput("header")),
                        br(),
                        rbokehOutput("plot_bokeh", height = "600px")
                    )
                )
            )
        )
    )
))
