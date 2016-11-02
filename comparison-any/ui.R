## Comparison Tool - Any District
# ui.R

shinyUI(navbarPage("Comparison Tool", position = "fixed-top",

    tabPanel("District",
        fluidPage(theme = "doe-style.css",
            br(),
            br(),
            br(),
            br(),
            fluidRow(
                column(3, offset = 1,
                    wellPanel(
                        selectInput(inputId = "district", label = "Select a district:", choices = sort(ach_profile$District)),
                        br(),
                        uiOutput("comparison_districts"),
                        br(),
                        selectInput(inputId = "outcome", label = "Select an outcome:", choices = outcome_list, selected = "Math", width = 400)
                    ),
                    p("Click", a(href = "https://tnedu.shinyapps.io/comparison-tool", "here"), "to compare against demographically similar districts.")
                ),
                column(7,
                    tabsetPanel(type = "tabs",
                        tabPanel("Current Year",
                            ggvisOutput("plot")
                        ),
                        tabPanel("Historical Data",
                            ggvisOutput("historical_plot")
                        )
                    )
                )
            ),
            fluidRow(
                column(10, offset = 1,
                       hr(),
                       p("Designed in", tags$a(href = "http://shiny.rstudio.com/", "Shiny"), "for the Tennessee Department of Education.",
                         tags$a(href = "https://github.com/alexander-poon/shiny-apps", "Source Code"), style = "font-size: 8pt"),
                       p("Questions, Suggestions, or Errors?", tags$a(href = "mailto:alex.poon@tn.gov", "Email Me"), style = "font-size: 8pt"),
                       br(),
                       br()
                )
            )
        )
    )
))
