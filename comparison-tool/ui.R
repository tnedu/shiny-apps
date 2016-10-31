## District Comparison Tool
# ui.R

shinyUI(navbarPage("Comparison Tool", position = "fixed-top",

    tabPanel("District",
        fluidPage(theme = "doe-style.css",
            useShinyjs(),
            br(),
            br(),
            br(),
            br(),
            fluidRow(
                # Column with input panels
                column(3, offset = 1,
                    wellPanel(
                        h4("Identify Similar Districts"),
                        br(),
                        selectInput(inputId = "district", label = "Select a District:", choices = sort(chars_std$District)),
                        br(),
                        checkboxGroupInput(inputId = "district_chars",
                            label = "Select One or More District Characteristics:",
                            choices = c("Student Enrollment" = "Enrollment",
                                "Per-Pupil Expenditures" = "Per-Pupil Expenditures",
                                "% Economically Disadvantaged" = "Economically Disadvantaged",
                                "% Students with Disabilities" = "Students with Disabilities",
                                "% English Learner Students" = "English Learners",
                                "% Black Students" = "Black",
                                "% Hispanic Students" = "Hispanic",
                                "% Native American Students" = "Native American"
                            ),
                            selected = c("Enrollment", "Black", "Hispanic", "Native American", "English Learners", "Economically Disadvantaged", "Students with Disabilities", "Per-Pupil Expenditures")
                        ),
                        br(),
                        actionButton(inputId = "button", label = "Go!"),
                        hidden(tags$div(id = "info",
                            "Adjust any of the inputs in the left panels to update the output.")
                        )
                    ),
                    conditionalPanel("input.button >= 1",
                        wellPanel(
                            h4("Outcome"),
                            br(),
                            selectInput(inputId = "outcome", label = "Select an outcome to plot:", choices = outcome_list, selected = "Math", width = 400)
                        ),
                        wellPanel(
                            h4("Additional Options"),
                            br(),
                            sliderInput(inputId = "num_districts", label = "Number of comparison districts:", min = 1, max = 9, value = 5, step = 1, ticks = FALSE),
                            br(),
                            tags$b("Restrict comparison districts to the same:"),
                            checkboxInput(inputId = "restrict_CORE", label = "CORE Region", value = FALSE)
                        ),
                        p("Read", a(href = "https://github.com/tnedu/shiny-apps/blob/master/comparison-tool/documentation.md", "methodology"),
                          "for identifying similar districts."),
                        p("Click", a(href = "https://tnedu.shinyapps.io/comparison-any", "here"), "if you would prefer to select comparison districts.")
                    )
                ),
                # Message to be shown on initializing
                conditionalPanel("input.button == 0",
                    column(7,
                        h4("Using the input widgets on the left, select a school district and one or more district characteristics."),
                        br(),
                        p("For the selected district, this tool will identify the most similar districts based on the selected
                            characteristics and display data for a selected outcome."),
                        br(),
                        p("Click", a(href = "https://tnedu.shinyapps.io/comparison-any", "here"), "if you would prefer to select comparison districts.")
                    )
                ),
                # Message to be shown if no characteristics are selected
                hidden(tags$div(id = "request_input",
                    fluidRow(
                        h4("Please select one or more district characteristics.")
                    )
                )),
                # Column with plot, table output
                tags$div(id = "output",
                    conditionalPanel("input.button >= 1",
                        column(7,
                            h4(textOutput("header_bar")),
                            br(),
                            tabsetPanel(type = "tabs",
                                tabPanel("Current Year",
                                    br(),
                                    ggvisOutput("plot_outcome")
                                ),
                                tabPanel("Historical Data",
                                    br(),
                                    ggvisOutput("plot_hist")
                                )
                            ),
                            br(),
                            tags$b(p("Comparison districts are ordered from most (left) to least (right) similar.
                                Click on any bar/line to compare district profile data below.")),
                            br(),
                            h4(textOutput("header_comp")),
                            br(),
                            tableOutput("table_profile")
                        )
                    )
                )
            ),
            fluidRow(
                column(10, offset = 1,
                    hr(),
                    p("Designed in", tags$a(href = "http://shiny.rstudio.com/", "Shiny"), "for the Tennessee Department of Education.",
                        tags$a(href = "https://github.com/tnedu/shiny-apps/tree/master/data-explorer", "Source Code"), style = "font-size: 8pt"),
                    br(),
                    br()
                )
            )
        )
    )
))
