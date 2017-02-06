## District Data Explorer
# ui.R

shinyUI(navbarPage("Data Explorer",
    tabPanel("District",
        fluidRow(
            column(3, offset = 1,
                strong(p("This tool allows users to explore relationships between
                    district characteristics and outcomes for Tennessee school districts.")),
                p("Use the dropdowns below to select a district characteristic
                    and an outcome to plot."),
                br(),
                selectInput(inputId = "year", label = "School Year",
                    choices = c("2014-15" = 2015, "2015-16" = 2016), selected = 2016),
                selectInput(inputId = "char", label = "Select a District Characteristic:",
                    choices = chars, selected = "ED"),
                selectInput(inputId = "outcome", label = "Select an Outcome:",
                    choices = outcomes, selected = "Algebra I"),
                selectInput(inputId = "color", label = "Color Points by:",
                    choices = c("", color_by), selected = ""),
                selectInput(inputId = "highlight", label = "Highlight a District:",
                    choices = c("", sort(unique(ach_profile$District))), selected = ""),
                br(),
                downloadLink('downloadData', 'Click here'), "to download the data for this tool."
            ),
            column(7,
                rbokehOutput("scatter", height = "650px")
            )
        ),
        br(),
        conditionalPanel(condition = "input.highlight != ''",
            fluidRow(
                column(10, offset = 1,
                    tabsetPanel(
                        tabPanel("District Information",
                            fluidRow(
                                column(7,
                                    leafletOutput("map")
                                ),
                                column(5,
                                    br(),
                                    htmlOutput("district_info")
                                )
                            )
                        ),
                        tabPanel("Achievement",
                            fluidRow(
                                br(),
                                column(7,
                                    rbokehOutput("prof", height = "650px")
                                ),
                                column(5,
                                    "On Track/Mastered Percentages are shown for subjects with 10 or more tests and do not
                                    reflect accountability rules (e.g., Algebra I reassigned to Math for 8th graders)."
                                )
                            )
                        ),
                        tabPanel("Growth",
                            fluidRow(
                                br(),
                                column(7,
                                    tableOutput("tvaas_table")
                                ),
                                column(5,
                                    strong(p("The Tennessee Value-Added Assessment System (TVAAS) measures student growth on TNReady assessments.")),
                                    p("A TVAAS Level 4 or 5 indicates that students made more than the expected growth."),
                                    p("A TVAAS Level 3 indicates that students made the expected growth."),
                                    p("A TVAAS Level 1 or 2 indicates that students made less than the expected growth.")
                                )
                            )
                        ),
                        tabPanel("Ready Graduate",
                            br(),
                            fluidRow(
                                column(7,
                                    rbokehOutput("grad_chart", height = "650px")
                                ),
                                column(5,
                                    p("Graduation Rate is the percentage of students earning a high school diploma within four years and a summer.")
                                )
                            )
                        )
                        # tabPanel("Opportunity to Learn"),
                        # tabPanel("English Proficiency")
                    )
                )
            ),
            fluidRow(
                column(10, offset = 1,
                    hr(),
                    p("Click the button below to download this data in a document."),
                    downloadButton("report", "Download Report")
                )
            )
        ),
        fluidRow(
            column(10, offset = 1,
                hr(),
                p("Built in", tags$a(href = "http://shiny.rstudio.com/", "Shiny"), "for the Tennessee Deparment of Education."),
                br(),
                br()
            )
        )
    )
))
