## Report Card
# ui.R

dashboardPage(
    dashboardHeader(title = "Accountability Data Tool", titleWidth = 300),

    dashboardSidebar(width = 300,
        sidebarMenu(id = "sidebarmenu",
            menuItem("District", icon = icon("institution"),
                menuSubItem(text = "Accountability", tabName = "district_acct", icon = icon("bar-chart")),
                menuSubItem(text = "Comparison", tabName = "district_comp", icon = icon("exchange"))
            ),
            conditionalPanel("input.sidebarmenu == 'district_acct' | input.sidebarmenu == 'district_comp'",
                selectInput("district", label = "Select a District:", choices = district_list)),
            menuItem("School", icon = icon("graduation-cap"),
                menuSubItem(text = 'Accountability', tabName = 'school_acct', icon = icon("bar-chart")))
        )
    ),

    dashboardBody(
        tabItems(
            tabItem(tabName = "district_acct",
                fluidRow(
                    column(12,
                        h1(textOutput("header_dist")),
                        br(),
                        br()
                    )
                ),
                fluidRow(
                    column(12,
                        valueBoxOutput("gateBox", width = 12)
                    )
                ),
                fluidRow(
                    column(6,
                        box(title = "Participation Data", status = "primary", solidHeader = TRUE, 
                            width = 12, collapsible = TRUE, collapsed = TRUE,
                            formattableOutput("table_participation"),
                            tags$b("BHN"), "= Black/Hispanic/Native American", br(),
                            tags$b("ED"), "= Economically Disadvantaged", br(),
                            tags$b("SWD"), "= Students with Disabilities", br(),
                            tags$b("EL"), "= English Learners", br(),
                            tags$b("Super"), "= Super Subgroup, which consists of any student who is a member of the BHN, ED, SWD, or EL subgroups", br(),
                            hr(),
                            tags$b("Notes:"), br(),
                            "- A district is eligible for the participation test for a subgroup/subject
                            combination if it has at least 30 valid tests in the current year. 
                            Subgroup/Subject combinations with fewer than 30 valid tests are denoted with NA.",
                            br(),
                            "- For each eligible subgroup/subject combination, a district must have a
                            participation rate of 95% or greater to pass the participation test.",
                            br(),
                            "- A district which fails the participation test for any subgroup/subject
                            combination automatically receives a final determination of In Need of Improvement."
                        )
                    ),
                    column(6,
                        box(title = "Minimum Performance Data", status = "primary", solidHeader = TRUE, 
                                width = 12, collapsible = TRUE, collapsed = TRUE)
                    )
                ),
                fluidRow(
                    column(12,
                        valueBoxOutput("achBox", width = 6),
                        valueBoxOutput("gapBox", width = 6)
                    )
                ),
                fluidRow(
                    column(6,
                        box(title = "Achievement Data", status = "primary", solidHeader = TRUE, 
                                width = 12, collapsible = TRUE, collapsed = TRUE,
                            tableOutput("ach_heatmap")
                        )
                    ),
                    column(6,
                        box(title = "Gap Closure Data", status = "primary", solidHeader = TRUE, 
                               width = 12, collapsible = TRUE, collapsed = TRUE)
                    )
                ),
                fluidRow(
                    column(12,
                        valueBoxOutput("finalBox", width = 12)
                    )
                )
            ),
            tabItem(tabName = "district_comp",
                h1("District Comparison Tool")
            ),
            tabItem(tabName = "school_acct",
                h1("School Accountability")
            )
        )
    )
)