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
                                choices = c(district_list), selected = NULL, width = 500)
                ),
                column(3,
                    selectInput("outcome", label = "Select an Outcome:", 
                                choices = district_out, selected = "Math", width = 500)
                ),
                column(4,
                    wellPanel("This tool is designed to help users explore the relationships between
                              district characteristics and outcomes for school districts in the State
                              of Tennessee.",
                              tags$br(),
                              tags$br(),
                              "Use the dropdowns on the left to select a district characteristic 
                              and an outcome to plot.",
                              tags$br(),
                              tags$br(),
                              "You may also click on any point on the graph for more information
                              on that district.")
                )
            )
        ) 
    )
))