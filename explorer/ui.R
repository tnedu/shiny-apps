## District Explorer
# ui.R

shinyUI(navbarPage(title = "Data Explorer",

    tabPanel("Plot", icon = icon("line-chart"),
        fluidRow(
            column(3, offset = 1,
                strong(p("This tool allows users to explore characteristics
                    and outcomes for Tennessee school districts.")),
                p("Use the dropdowns below to select a characteristic
                    and an outcome to plot."),
                br(),
                selectInput(inputId = "year", label = "School Year",
                    choices = c("2015-16" = 2016, "2014-15" = 2015)),
                selectInput(inputId = "char", label = "Select a District Characteristic:",
                    choices = chars, selected = "ED"),
                selectInput(inputId = "outcome", label = "Select an Outcome:",
                    choices = outcomes, selected = "Algebra I"),
                selectInput(inputId = "color", label = "Color Points by:",
                    choices = c("", color_by)),
                selectInput(inputId = "highlight", label = "Highlight a District:",
                    choices = c("", sort(unique(ach_profile$District)[-1])))
            ),
            column(7,
                rbokehOutput("scatter", height = "650px")
            )
        ),
        fluidRow(
            column(10, offset = 1,
                hr(),
                p("Created in", tags$a(href = "http://shiny.rstudio.com/", "Shiny"),
                    "for the Tennessee Department of Education."),
                br(),
                br()
            )
        )
    ),

    tabPanel("Map", icon = icon("map-o"),
        div(class = "outer",
            tags$head(includeCSS("www/styles.css")),
            leafletOutput("map", width = "100%", height = "100%"),
            absolutePanel(class = "map_control", top = 25, right = 10,
                br(),
                selectInput(inputId = "map_var", label = "Select something to map:",
                    choices = c("", outcomes_map), selected = ""),
                selectInput(inputId = "year_map", label = "School Year",
                    choices = c("2015-16" = 2016, "2014-15" = 2015))
            )
        )
    ),

    tabPanel("Data", icon = icon("reorder"),
        fluidRow(
            column(3, offset = 1,
                checkboxGroupInput("table_vars", label = "Select some variables:",
                    choices = unlist(outcomes_map, use.names = FALSE),
                    selected = c("Algebra I", "ED")),
                br(),
                downloadLink('downloadData', 'Click here'), "to download data as a .csv file."
            ),
            column(7,
                DT::dataTableOutput("table")
            )
        )
    )

))
