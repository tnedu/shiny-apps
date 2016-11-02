## Data Explorer
# ui.R

function(request) {

    shinyUI(navbarPage("Data Explorer", position = "fixed-top",
        tabPanel("District",
            fluidPage(theme = "doe-style.css",
                br(),
                br(),
                br(),
                fluidRow(
                    column(10, offset = 1,
                        hr(),
                        h2("User Inputs"),
                        br()
                    )
                ),
                fluidRow(
                    column(3, offset = 1,
                        selectInput("char", label = "Select a District Characteristic:", 
                            choices = district_char, selected = "Economically Disadvantaged", width = 500),
                        uiOutput("slider")
                    ),
                    column(3,
                        selectInput("outcome", label = "Select an Outcome:", 
                            choices = district_out, selected = "Math", width = 500),
                        selectInput("color", label = "Color points by:",
                            choices = district_cat, selected = "Region", width = 500),
                        selectInput("district", label = "Optional: Highlight a District", 
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
                        h2("District Data"),
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
                            h2("Information for Users"),
                            br(),
                            tags$ul(
                                tags$li("Each point represents one district."),
                                tags$li(textOutput("info1")),
                                tags$li(textOutput("info2")),
                                tags$li("Proficiency data are shown for districts with 10 or more tests in the selected subject
                                    and do not reflect accountability rules (e.g., Algebra I reassigned to Math for 8th graders)."),
                                tags$li("Hover or click on any point for more information about that district.")
                            )
                    ),
                    column(4,
                        wellPanel(
                            h4("Share this plot"),
                            bookmarkButton(),
                            br(),
                            br(),
                            p("Click the", icon("gear"), "icon at the top right of each plot to 
                                download a copy of that plot.")
                        )
                    )
                ),
                fluidRow(
                    column(10, offset = 1,
                        hr(),
                        p("Designed in", tags$a(href = "http://shiny.rstudio.com/", "Shiny"), "for the Tennessee Department of Education.",
                        tags$a(href = "https://github.com/tnedu/shiny-apps/tree/master/comparison-tool", "Source Code"), style = "font-size: 8pt"),
                        p("Questions, Suggestions, or Errors?", tags$a(href = "mailto:alex.poon@tn.gov", "Email Me"), style = "font-size: 8pt"),
                        br(),
                        br()
                    )
                )
            ) 
        )
    ))
}