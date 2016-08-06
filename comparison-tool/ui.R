## District Comparison Tool
# ui.R

shinyUI(navbarPage("Comparison Tool", position = "fixed-top",

    tabPanel("District",
        fluidPage(theme = "doe-style.css",
            useShinyjs(),
            br(),
            br(),
            br(),
            br(),
            fluidRow(
                # Column with input panels
                column(3, offset = 1,
                    wellPanel(
                        tags$b(p("Select a school district and one or more district characteristics below.")),
                        br(),
                        p("For the selected district, this tool will identify the most similar districts
                            based on the selected characteristics and display data for a selected outcome."),
                        br(),
                        selectInput(inputId = "district", label = "Select a District:", choices = df_std$system_name),
                        br(),
                        checkboxGroupInput(inputId = "district_chars", 
                            label = "Select One or More District Characteristics:",
                            choices = c("Student Enrollment" = "Enrollment", 
                                "% Black Students" = "Pct_Black",
                                "% Hispanic Students" = "Pct_Hispanic",
                                "% Native American Students" = "Pct_Native_American",
                                "% English Learner Students" = "Pct_EL",
                                "% Economically Disadvantaged" = "Pct_ED",
                                "% Students with Disabilities" = "Pct_SWD",
                                "Per-Pupil Expenditures" = "Per_Pupil_Expenditures"),
                            selected = c("Enrollment", "Pct_Black", "Pct_Hispanic", "Pct_Native_American", "Pct_EL", "Pct_ED", "Pct_SWD", "Per_Pupil_Expenditures")
                        ),
                        br(),
                        selectInput(inputId = "outcome", label = "Select an outcome to plot:", choices = outcome_list, selected = "Math", width = 400)
                    ),
                    wellPanel(
                        tags$b("Additional Options"),
                        br(),
                        br(),
                        sliderInput(inputId = "num_districts", label = "Number of comparison districts:", min = 1, max = 10, value = 7, step = 1, ticks = FALSE),
                        br(),
                        tags$b("Restrict comparison districts to the same:"),
                        checkboxInput(inputId = "restrict_CORE", label = "CORE Region", value = FALSE)
                    )
                ),
                # Message to be shown if no characteristics are selected
                hidden(tags$div(id = "request_input",
                    fluidRow(
                        h4("Please select one or more district characteristics.")
                    )
                )),
                # Column with plot, table output
                tags$div(id = "output",
                    column(7,
                        h4(textOutput("header_bar")),
                        br(),
                        tabsetPanel(type = "tabs",
                            tabPanel("Current Year",
                                br(),
                                ggvisOutput("plot_prof")
                            ),
                            tabPanel("Historical Data",
                                br(),
                                ggvisOutput("plot_hist")
                            )
                        ),
                        br(),
                        tags$b("Click on any bar/line to compare district profile data below."),
                        br(),
                        br(),
                        h4(textOutput("header_comp")),
                        br(),
                        tabsetPanel(type = "tabs",
                            tabPanel("Plot",
                                br(),
                                ggvisOutput("plot_char"),
                                br(),
                                "A percentile indicates the proportion of districts with 
                                an equal or smaller value of that characteristic."
                            ),
                            tabPanel("Table",
                                br(),
                                tableOutput("table"),
                                br(),
                                "Differences of more than half and a full a standard deviation are
                                highlighted in yellow and orange, respectively."
                            )
                        )
                    )
                )
            ),
            fluidRow(
                column(10, offset = 1,
                    hr(),
                    p("Designed by", tags$a(href = "mailto:alex.poon@tn.gov", "Alexander Poon"), "in",
                        tags$a(href = "http://shiny.rstudio.com/", "Shiny"), "for the Tennessee Department of Education.",
                        tags$a(href = "https://github.com/tnedu/shiny-apps/tree/master/data-explorer", "Source Code"), style = "font-size: 8pt"),
                    br(),
                    br()
                )
            )
        )
    )
))
