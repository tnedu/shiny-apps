## Data Explorer
# ui.R

shinyUI(navbarPage("Data Explorer", position = "fixed-top",

    tabPanel("District",
        fluidPage(theme = "doe-style.css",
            br(),
            br(),
            br(),
            fluidRow(
                column(10, offset = 1,
                    hr(),
                    h3("User Inputs"),
                    br()
                )
            ),
            fluidRow(
                column(3, offset = 1,
                    selectInput("char", label = "Select a District Characteristic:", 
                        choices = district_char, selected = "Pct_ED", width = 500),
                    uiOutput("slider")
                ),
                column(3,
                    selectInput("outcome", label = "Select an Outcome:", 
                        choices = district_out, selected = "Math", width = 500),
                    selectInput("highlight", label = "Optional: Highlight a District", 
                        choices = district_list, selected = NULL, width = 500)
                ),
                column(4,
                    wellPanel(
                        tags$b(p("This tool allows users to explore relationships between
                        district characteristics and outcomes for Tennessee school districts.")),
                        p("Use the dropdowns on the left to select a district characteristic 
                            and an outcome to plot.")
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
                    h3("District Data"),
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
                        h3("Information for Users"),
                        br(),
                        tags$ul(
                            tags$li("Each point represents one district."),
                            tags$li(textOutput("info1")),
                            tags$li(textOutput("info2")),
                            tags$li("Proficiency data are only shown for districts with 10 or more tests in the selected subject."),
                            tags$li("The proficiency numbers shown do not have accountability rules applied 
                                (e.g.: Algebra I reassigned to Math for 8th graders)."),
                            tags$li("Hover or click on any point for more information about that district.")
                        ),
                        br(),
                        br(),
                        h4("About Tennessee's CORE Regions"),
                        br(),
                        p("Tennessee divides its school districts into 8 Centers of Regional Excellence:"),
                        br(),
                        tags$div(img(src = "CORE_districts.png", width = "90%")),
                        br(),
                        p("Please visit", tags$a(href = "http://www.tn.gov/education/topic/centers-of-regional-excellence", "http://www.tn.gov/education/topic/centers-of-regional-excellence"), "for more information.")
                ),
                column(4,
                    wellPanel(
                        h4("Share this plot"),
                        br(),
                        shinyURL.ui(label = "Use the following web address to link to this plot:"),
                        p("We recommend clicking the TinyURL button for a more compact address.")
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