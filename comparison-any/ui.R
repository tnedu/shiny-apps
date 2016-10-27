## Comparison Tool - Any District
# ui.R

shinyUI(
    fluidPage(
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
                )
            ),
            column(7,
                ggvisOutput("plot")
            )
        ),
        fluidRow(
            column(10, offset = 1,
                   hr(),
                   p("Designed in", tags$a(href = "http://shiny.rstudio.com/", "Shiny"), "for the Tennessee Department of Education.",
                     tags$a(href = "https://github.com/alexander-poon/shiny-apps", "Source Code"), style = "font-size: 8pt"),
                   br(),
                   br()
            )
        )
    )
)
