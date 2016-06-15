## Report Card
# ui.R

dashboardPage(
    dashboardHeader(title = "Accountability Data Tool", titleWidth = 250),

    dashboardSidebar(width = 250,
        sidebarMenu(id = "sidebarmenu",
            menuItem("District", icon = icon("institution"),
                menuSubItem(text = "Accountability", tabName = "district_acct", icon = icon("bar-chart")),
                menuSubItem(text = "Comparison", tabName = "district_comp", icon = icon("exchange"))
            ),
            conditionalPanel("input.sidebarmenu == 'district_acct'",
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
                        valueBoxOutput("gateBox", width = 4),
                        valueBoxOutput("achBox", width = 4),
                        valueBoxOutput("gapBox", width = 4)
                    )
                ),
                fluidRow(
                    column(12,
                        valueBoxOutput("finalBox", width = 12)
                    )
                )
            ),
            tabItem(tabName = "district_comp",
                h2("District Comparison Tool")
            ),
            tabItem(tabName = "school_acct",
                h2("School Accountability")
            )
        )
    )
)