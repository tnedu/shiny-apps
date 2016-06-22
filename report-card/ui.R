## Report Card
# ui.R

dashboardPage(

    dashboardHeader(title = "Accountability Data Tool", titleWidth = 300),

    dashboardSidebar(width = 300,
        sidebarMenu(id = "sidebarmenu",
            menuItem("District", icon = icon("institution"),
                menuSubItem(text = "Data Explorer", tabName = "district_explorer", icon = icon("search")),
                menuSubItem(text = "District Profile", tabName = "district_profile", icon = icon("dashboard")),
                menuSubItem(text = "Accountability", tabName = "district_acct", icon = icon("bar-chart")),
                menuSubItem(text = "District Comparison", tabName = "district_comp", icon = icon("exchange"))
            ),
            conditionalPanel("input.sidebarmenu == 'district_profile' | input.sidebarmenu == 'district_acct' | input.sidebarmenu == 'district_comp'",
                selectInput("district", label = "Select a District:", choices = district_list)
            ),
            menuItem("School", icon = icon("graduation-cap"),
                menuSubItem(text = 'Accountability', tabName = 'school_acct', icon = icon("bar-chart"))
            )
        )
    ),

    dashboardBody(
        tabItems(
            tabItem(tabName = "district_explorer",
                    h1("District Data Explorer")
            ),
            tabItem(tabName = "district_profile",
                    h1("District Profile")
            ),
            tabItem(tabName = "district_acct",
                fluidRow(
                    column(12,
                        h1(textOutput("header_dist")),
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
                            combination if it has at least 30 valid tests in the current year.",
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
                                width = 12, collapsible = TRUE, collapsed = TRUE,
                            tableOutput("gate_heatmap"),
                            br(),
                            tags$b("A district must meet all three goals to progress to the Achievement and Gap Closure Determinations")
                        )
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
                        box(title = "Achievement Heat Map", status = "primary", solidHeader = TRUE, 
                                width = 12, collapsible = TRUE, collapsed = TRUE,
                            br(),
                            tableOutput("ach_heatmap"),
                            br(),
                            hr(),
                            tags$b("For the Achievement and TVAAS Goals, districts are assigned 0-4 
                                   points as per the following rules:"),
                            br(),
                            br(),
                            tableOutput("ach_legend"),
                            br(),
                            br(),
                            tags$b("A district's Achievement Score is the average of its Best Score across 
                                   content areas. For districts who meet the Minimum Performance Goal, the
                                   Achievement Score is then mapped to an achievement determination as follows:"),
                            br(),
                            br(),
                            tableOutput("ach_map")
                        )
                    ),
                    column(6,
                        box(title = "Gap Closure Heat Map", status = "primary", solidHeader = TRUE, 
                               width = 12, collapsible = TRUE, collapsed = TRUE,
                            tabBox(width = 12,
                                   tabPanel("Overall", tableOutput("final_gap")),
                                   tabPanel("BHN", tableOutput("bhn_gap")),
                                   tabPanel("ED", tableOutput("ed_gap")),
                                   tabPanel("EL", tableOutput("ell_gap")),
                                   tabPanel("SWD", tableOutput("swd_gap"))),
                            tags$b("For the Subgroup Achievement and TVAAS Goals, districts are assigned 0-4 
                                   points as per the following rules:"),
                            br(),
                            br(),
                            tableOutput("gap_legend"),
                            br(),
                            br(),
                            tags$b("A subgroup's Achievement Score is the average of its Best Score across 
                                   content areas. The four subgroup Achievement Scores are averaged to produce
                                   an Overall Gap Closure Score. For districts who meet the Minimum Performance
                                   Goal, the Overall Gap Closure Score is then mapped to an achievement determination
                                   as follows:"),
                            br(),
                            br(),
                            tableOutput("gap_map")
                        )
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