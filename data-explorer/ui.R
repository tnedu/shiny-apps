## Data Explorer
# ui.R

shinyUI(navbarPage("Data Explorer", position = "fixed-top",

    tabPanel("District",
        fluidPage(
            fluidRow(
                br(),
                br(),
                br(),
                column(6, offset = 1,
                    h3("All District Data"),
                    ggvisOutput("plot")
                ),
                column(4,
                       br(),
                       h4(textOutput("text1")),
                       ggvisOutput("plot2"),
                       h4(textOutput("text2")),
                       ggvisOutput("plot3")
                )
            ),
            fluidRow(
                column(10, offset = 1,
                    hr()
                )
            ),
            fluidRow(
                column(3, offset = 1,
                    selectInput("char", label = "Select a District Characteristic:", 
                                choices = district_char, selected = "Pct_ED", width = 500),
                    selectInput("highlight_dist", label = "Optional: Highlight a District", 
                                choices = district_list, selected = NULL, width = 500)
                ),
                column(3,
                    selectInput("outcome", label = "Select an Outcome:", 
                                choices = district_out, selected = "Math", width = 500)
                ),
                column(4,
                    wellPanel(strong("This tool is designed to help users explore relationships between
                              district characteristics and outcomes for Tennessee school districts."),
                              br(),
                              br(),
                              "Use the dropdowns on the left to select a district characteristic 
                              and an outcome to plot.",
                              br(),
                              br(),
                              "Click on any point on the graph for more information on that district.")
                )
            ),
            br(),
            br(),
            br(),
            fluidRow(
                column(10, offset = 1,
                       hr(),
                       p("Designed by Alexander Poon in", tags$a(href = "http://shiny.rstudio.com/", "Shiny"), 
                         "for the Tennessee Department of Education.",
                         tags$a(href = "https://github.com/alexander-poon/shiny-apps/tree/master/comparison-tool", "Source Code"), style = "font-size: 8pt"),
                       br(),
                       br()
                )
            )
        ) 
    )
))