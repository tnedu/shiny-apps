## Data Explorer - Motion Chart
# ui.R

shinyUI(
    fluidPage(

        fluidRow(
            column(10, offset = 1,
                h2("Data Explorer")
            )
        ),
        fluidRow(
            column(10, offset = 1,
                htmlOutput("chart")
            )
        ),
        fluidRow(
            column(10, offset = 1,
                hr(),
                p("Designed by", tags$a(href = "mailto:alex.poon@tn.gov", "Alexander Poon"),
                    "in", tags$a(href = "http://shiny.rstudio.com/", "Shiny"), "for the Tennessee Department of Education.",
                    tags$a(href = "https://github.com/alexander-poon/shiny-apps", "Source Code"), style = "font-size: 8pt"),
                br(),
                br()
            )
        )
    )
)
