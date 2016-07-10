## Data Explorer
# server.R

shinyServer(function(input, output, session) {

    # Adjust color, opacity of highlighted district
    df_highlight <- reactive({
    
        # Variables to assign State different color, opacity
        df$state <- as.numeric(df$system_name == "State of Tennessee")
        df$opac <- 0.3
        df[df$system_name == "State of Tennessee", ]$opac <- 1
        
        if (input$highlight != "") {
            df[df$system_name == input$highlight, ]$state <- 2
            df[df$system_name == input$highlight, ]$opac <- 1
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
                    row[names(row) == input$outcome])
    }

    # Extract district of clicked point for secondary graphs; Update highlighted district on point click
    click_district <- function(data, ...) {
        updateSelectInput(session, "highlight", selected = as.character(data$system_name))
    }

    # Main plot - Scatterplot of district characteristic X outcome
    plot <- reactive({

        # Axis Labels
        xvar_name <- names(district_char)[district_char == input$char]
        yvar_name <- names(district_out)[district_out == input$outcome]

        # Convert input (string) to variable name
        xvar <- prop("x", as.symbol(input$char))
        yvar <- prop("y", as.symbol(input$outcome))

        # Scale vertical axis to [0, 100] if outcome is a %P/A, otherwise, scale to min/max of variable
        if (grepl("Percent Proficient or Advanced", yvar_name)) {
            y_scale <- c(0, 100)
        } else {
            y_scale <- c(min(df_highlight()[names(df_highlight()) == input$outcome]), 
                         ceiling(max(df_highlight()[names(df_highlight()) == input$outcome])))
        }

        df_highlight() %>%
            ggvis(xvar, yvar, key := ~system_name) %>%
            layer_points(fill = ~factor(state),
                         size := 125, size.hover := 300,
                         opacity = ~factor(opac), opacity.hover := 0.8) %>%
            add_axis("x", title = xvar_name, grid = FALSE) %>%
            add_axis("y", title = yvar_name, grid = FALSE) %>%
            scale_numeric("y", domain = y_scale) %>%
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
            filter(system_name == input$highlight) %>%
            select(one_of(c("system_name", "Pct_BHN", "Pct_ED", "Pct_EL", "Pct_SWD"))) %>%
            rename("Black/Hispanic/Native American" = Pct_BHN, "Economically Disadvantaged" = Pct_ED, "English Learners" = Pct_EL, "Students with Disabilities" = Pct_SWD) %>%
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

    plot2 %>% bind_shiny("plot2")

    output$text1 <- renderText({paste(input$highlight, "Demographics", sep = " ")})

    # Create tooltip for bar chart with subject, proficiency percentages
    tooltip_bar <- function(x) {
        if (is.null(x)) return(NULL)
        long <- df %>%
            filter(system_name == input$highlight) %>%
            select(one_of(c("system_name", "AlgI", "AlgII", "BioI", "Chemistry", 
                            "EngI", "EngII", "EngIII", "Math", "ELA", "Science"))) %>%
            gather("subject", "Pct_Prof_Adv", 2:11) %>%
            filter(subject == x$subject)

        paste0("<b>", long$subject, "</b><br>",
               "Percent Proficient/Advanced: ", long$Pct_Prof_Adv, "%")
    }

    # Extract subject of clicked bar to update main plot
    click_subject <- function(data, ...) {
        updateSelectInput(session, "outcome", selected = as.character(data$subject))
    }

    # Secondary plot 2 - Bar chart of proficiency for selected district
    plot3 <- reactive({

        district_data <- df_highlight() %>%
                            filter(system_name == input$highlight) %>%
                            select(one_of(c("system_name", "AlgI", "AlgII", "BioI", "Chemistry",
                                "ELA", "EngI", "EngII", "EngIII", "Math", "Science"))) %>%
                            gather("subject", "Pct_Prof_Adv", 2:11)

        district_data %>%
            ggvis(~factor(subject), ~Pct_Prof_Adv, key := ~subject) %>%
            layer_bars(fill := "blue", fillOpacity := 0.3, fillOpacity.hover := 0.8) %>%
            add_axis("x", title = "Subject", grid = FALSE) %>%
            add_axis("y", title = "Percent Proficient or Advanced", grid = FALSE) %>%
            add_tooltip(tooltip_bar, on = "hover") %>%
            scale_ordinal("x", domain = c("Math", "ELA", "Science", "AlgI", "AlgII", "EngI", "EngII", "EngIII", "BioI", "Chemistry")) %>%
            scale_numeric("y", domain = c(0, 100)) %>%
            set_options(width = 'auto', height = 350) %>%
            handle_click(click_subject)

    })

    plot3 %>% bind_shiny("plot3")

    output$text2 <- renderText({paste(input$highlight, "Proficiency in All Subjects", sep = " ")})

    # ShinyURL function to save link
    shinyURL.server()

    }
)