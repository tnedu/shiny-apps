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
                    ggvisOutput("plot"),
                    hr()
                ),
                column(4,
                       br(),
                       h4(textOutput("text1")),
                       ggvisOutput("plot3"),
                       hr(),
                       h4(textOutput("text2")),
                       ggvisOutput("plot2")
                       
                )
            ),
            fluidRow(
                column(3, offset = 1,
                    selectInput("char", label = "Select a District Characteristic:", 
                                choices = district_char, selected = "Pct_ED", width = 500),
                    selectInput("highlight_dist", label = "Optional: Highlight a District", 
                                choices = c("", district_list), selected = NULL, width = 500)
                ),
                column(3,
                    selectInput("outcome", label = "Select an Outcome:", 
                                choices = district_out, selected = "Math", width = 500)
                )
            )
        ) 
    )
))