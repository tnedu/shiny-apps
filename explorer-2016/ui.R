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
                                column(6,
                                    leafletOutput("map")
                                ),
                                column(6,
                                    br(),
                                    htmlOutput("district_info")
                                )
                            )
                        ),
                        tabPanel("Achievement",
                            fluidRow(
                                column(8,
                                    rbokehOutput("prof", height = '700px')
                                ),
                                column(4,
                                    br(),
                                    "On track/Mastered Percentages are shown for subjects 10 or more tests and do not
                                    reflect accountability rules (e.g., Algebra I reassigned to Math for 8th graders)."
                                )
                            )
                        ),
                        tabPanel("Growth",
                            fluidRow(
                                column(12,
                                    tableOutput("tvaas_table")
                                )
                            )
                        )
                        # tabPanel("Ready Graduate"),
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
                p("Created with", tags$a(href = "http://hafen.github.io/rbokeh/index.html", "rbokeh"), "and", tags$a(href = "http://shiny.rstudio.com/", "Shiny.")),
                br(),
                br()
            )
        )
    )
))
