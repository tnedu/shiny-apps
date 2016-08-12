## Data Explorer
# ui.R

shinyUI(navbarPage("Data Explorer", position = "fixed-top",

    tabPanel("District",
        fluidPage(theme = "doe-style.css",
            br(),
            br(),
            fluidRow(
                column(10, offset = 1,
                    hr()
                )
            ),
            fluidRow(
                column(3, offset = 1,
                    selectInput("char", label = "Select a District Characteristic:", 
                        choices = district_char, selected = "Pct_ED", width = 500),
                    selectInput("highlight", label = "Optional: Highlight a District", 
                        choices = district_list, selected = NULL, width = 500)
                ),
                column(3,
                    selectInput("outcome", label = "Select an Outcome:", 
                        choices = district_out, selected = "Math", width = 500)
                ),
                column(4,
                    wellPanel(
                        tags$b(p("This tool allows users to explore relationships between
                        district characteristics and outcomes for Tennessee school districts.")),
                        p("Use the dropdowns on the left to select a district characteristic 
                            and an outcome to plot."),
                        p("Click on any point on the graph for more information on that district.")
                    )
                )
            ),
            fluidRow(
                column(10, offset = 1,
                    hr()
                )
            ),
            fluidRow(
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
                column(6, offset = 1,
                    p("Tennessee is divided into 8 Centers of Regional Excellence as follows:"),
                    br(),
                    tags$div(img(src = "CORE_districts.png", width = "90%")),
                    br(),
                    p("Please visit", tags$a(href = "http://www.tn.gov/education/topic/centers-of-regional-excellence", "http://www.tn.gov/education/topic/centers-of-regional-excellence"), "for more information.")
                ),
                column(4,
                    wellPanel(
                        tags$b(p("Use the following web address to link to this plot.")),
                        "We recommend clicking the TinyURL button for a more compact address.",
                        shinyURL.ui(label = "")
                    )
                )
            ),
            fluidRow(
                column(10, offset = 1,
                    hr(),
                    p("Designed in", tags$a(href = "http://shiny.rstudio.com/", "Shiny"), "for the Tennessee Department of Education.",
                    tags$a(href = "https://github.com/tnedu/shiny-apps/tree/master/comparison-tool", "Source Code"), style = "font-size: 8pt"),
                    br(),
                    br()
                )
            )
        ) 
    )
))