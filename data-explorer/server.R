## Data Explorer
# server.R

shinyServer(function(input, output, session) {

    # Adjust color, opacity of highlighted district
    df_highlight <- reactive({

        if (input$highlight_dist != "") {
            df[df$system_name == input$highlight_dist, ]$state <- 2
            df[df$system_name == input$highlight_dist, ]$opac <- 1
        }

        # Filter for missing data based on input
        df[!is.na(df[names(df) == input$outcome]), ]

    })

    # Create tooltip with district name, selected x and y variables
    tooltip_scatter <- function(x) {
        if (is.null(x)) return(NULL)
        row <- df[df$system_name == x$system_name, ]

        paste0("<b>", row$system_name, "</b><br>",
               names(district_char)[district_char == input$char], ": ", 
                    row[names(row) == input$char], "<br>",
               names(district_out)[district_out == input$outcome], ": ",
                    row[names(row) == input$outcome], "%")
    }

    # Extract district number of clicked point for secondary graphs, set default to State (district = 0)
    # Update highlighted district on point click
    clicked <- reactiveValues(district = "State of Tennessee")

    click_district <- function(data, ...) {
        updateSelectInput(session, "highlight_dist", selected = as.character(data$system_name))
        clicked$district <- as.character(data$system_name)
        
        str(clicked$district)
    }

    # Main plot - Scatterplot of district characteristic X outcome
    plot <- reactive({

        # Axis Labels
        xvar_name <- names(district_char)[district_char == input$char]
        yvar_name <- names(district_out)[district_out == input$outcome]

        # Convert input (string) to variable name
        xvar <- prop("x", as.symbol(input$char))
        yvar <- prop("y", as.symbol(input$outcome))
        
        df_highlight() %>%
            ggvis(xvar, yvar, key := ~system_name) %>%
            layer_points(fill = ~factor(state),
                         size := 100, size.hover := 200,
                         opacity = ~factor(opac), opacity.hover := 0.8) %>%
            add_axis("x", title = xvar_name, grid = FALSE) %>%
            add_axis("y", title = yvar_name, grid = FALSE) %>%
            add_tooltip(tooltip_scatter, on = "hover") %>%
            scale_nominal("opacity", range = c(0.3, 1)) %>%
            scale_nominal("fill", range = c("blue", "red", "orange")) %>%
            hide_legend("fill") %>%
            set_options(width = 'auto', height = 725) %>%
            handle_click(click_district)

    })

    plot %>% bind_shiny("plot")

    # Secondary Plot 1 - Horizontal bar chart with demographics 
    plot2 <- reactive({

        district_data <- df_highlight() %>%
            filter(system_name == clicked$district) %>%
            select(one_of(c("system_name", "Pct_BHN", "Pct_ED", "Pct_EL", "Pct_SWD"))) %>%
            rename("% BHN" = Pct_BHN, "% ED" = Pct_ED, "% EL" = Pct_EL, "% SWD" = Pct_SWD) %>%
            gather("demographic", "Percentage", 2:5)

        district_data %>%
            ggvis(~Percentage, ~demographic) %>%
            layer_rects(x2 = 0, height = band(), 
                        fill := "blue", fillOpacity := 0.3, fillOpacity.hover := 0.8) %>%
            add_axis("x", grid = FALSE) %>%
            add_axis("y", title = "", grid = FALSE) %>%
            scale_numeric("x", domain = c(0, 100)) %>%
            set_options(width = 'auto', height = 350)
    
    })

    plot2 %>% bind_shiny("plot3")

    output$text1 <- renderText({paste(clicked$district, "Demographics", sep = " ")})

    # Secondary plot 2 - Bar chart of proficiency for selected district
    plot3 <- reactive({

        district_data <- df_highlight() %>%
                            filter(system_name == clicked$district) %>%
                            select(one_of(c("system_name", "AlgI", "AlgII", "BioI", "Chemistry", 
                                "ELA", "EngI", "EngII", "EngIII", "Math", "Science"))) %>%
                            gather("subject", "Pct_Prof_Adv", 2:11)

        # Convert subject variable to factor to order
        district_data$subject <- as.factor(district_data$subject)
        levels(district_data$subject) <- c("Math", "ELA", "Science", "AlgI", "AlgII", 
                                           "EngI", "EngII", "EngIII", "BioI", "Chemistry")

        district_data %>%
            ggvis(~factor(subject), ~Pct_Prof_Adv) %>%
            layer_bars(fill := "blue", fillOpacity := 0.3, fillOpacity.hover := 0.8) %>%
            add_axis("x", title = "Subject", grid = FALSE) %>%
            add_axis("y", title = "Percent Proficient or Advanced", grid = FALSE) %>%
            scale_numeric("y", domain = c(0, 100)) %>%
            set_options(width = 'auto', height = 350)

    })

    plot3 %>% bind_shiny("plot2")

    output$text2 <- renderText({paste(clicked$district, "Proficiency in All Subjects", sep = " ")})

    }
)