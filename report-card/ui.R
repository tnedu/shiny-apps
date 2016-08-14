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
            conditionalPanel("input.sidebarmenu == 'district_explorer'",
                selectInput("exp_char", label = "Select a District Characteristic:", choices = district_char, selected = "Pct_ED"),
                selectInput("exp_outcome", label = "Select a District Outcome:", choices = outcome_list),
                selectInput("highlight_dist", label = "Optional: Highlight a District", choices = c(" " = "State of Tennessee", district_list))
            ),
            conditionalPanel("input.sidebarmenu == 'district_profile' | input.sidebarmenu == 'district_acct' | input.sidebarmenu == 'district_comp'",
                selectInput("district", label = "Select a District:", choices = district_list)
            ),
            conditionalPanel("input.sidebarmenu == 'district_comp'",
                checkboxGroupInput("district_chars", label = "Select One or More District Characteristics:",
                    choices = c("Student Enrollment" = "Enrollment", 
                        "% Black Students" = "Pct_Black",
                        "% Hispanic Students" = "Pct_Hispanic",
                        "% Native American Students" = "Pct_Native_American",
                        "% English Learner Students" = "Pct_EL",
                        "% Economically Disadvantaged" = "Pct_ED",
                        "% Students with Disabilities" = "Pct_SWD",
                        "Per-Pupil Expenditures" = "Per_Pupil_Expenditures"),
                        selected = c("Enrollment", "Pct_Black", "Pct_Hispanic", "Pct_Native_American", "Pct_EL", "Pct_ED", "Pct_SWD", "Per_Pupil_Expenditures"
                    )
                ),
                selectInput("outcome", label = "Select an outcome to plot:", choices = outcome_list, selected = "Math", width = 300)
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
                h1(textOutput("header_dist_acct")),
                br(),
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
                            hr(),
                            tags$b("Notes:"), br(),
                            "- A district must meet all three goals to progress to the Achievement and Gap 
                            Closure Determinations",
                            br(),
                            "- A district which fails any of the Minimum Performance Goals automatically 
                            receives a final determination of In Need of Improvement"
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
                            tags$b("Notes:"), br(),
                            "- For the Achievement and TVAAS Goals, districts are assigned 0-4 
                            points as per the following rules:",
                            br(),
                            br(),
                            tableOutput("ach_legend"),
                            br(),
                            "- A district's Achievement Score is the average of its Best Score across 
                            content areas. For districts who meet the Minimum Performance Goal, the
                            Achievement Score is then mapped to an achievement determination as follows:",
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
                            tags$b("Notes:"), br(),
                            "- For the Subgroup Achievement and TVAAS Goals, districts are assigned 0-4 
                            points as per the following rules:",
                            br(),
                            br(),
                            tableOutput("gap_legend"),
                            br(),
                            "- A subgroup's Achievement Score is the average of its Best Score across 
                            content areas. The four subgroup Achievement Scores are averaged to produce
                            an Overall Gap Closure Score. For districts who meet the Minimum Performance
                            Goal, the Overall Gap Closure Score is then mapped to an achievement determination
                            as follows:",
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