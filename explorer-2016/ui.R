shinyUI(navbarPage("Data Explorer",
    tabPanel("District",

        fluidRow(
            column(3, offset = 1,
                strong(p("Use the dropdowns to select a District Characteristic and Outcome to plot:")),
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
                            ),
                            tabPanel("Accountability"),
                            tabPanel("Human Capital")
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
