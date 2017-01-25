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
                    choices = district_char, selected = "ED"),
                selectInput(inputId = "outcome", label = "Select an Outcome:",
                    choices = district_out, selected = "Algebra I"),
                selectInput(inputId = "color", label = "Color Points by:",
                    choices = c("", district_color), selected = NA),
                selectInput(inputId = "highlight", label = "Highlight a District:",
                    choices = c("", sort(unique(ach_profile$District))), selected = NA)
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
                                    strong(textOutput("district_name")),
                                    br(),
                                    textOutput("grades_served"),
                                    textOutput("number_schools"),
                                    textOutput("pct_bhn"),
                                    textOutput("pct_ed"),
                                    textOutput("pct_swd"),
                                    textOutput("pct_el")
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
                        )
                    )
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
