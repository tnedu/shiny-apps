## Comparison Tool - Any District
# server.R

shinyServer(function(input, output) {

    output$comparison_districts <- renderUI({
        selectizeInput(inputId = "comparison", label = "Select one or more comparison districts (Maximum 7):",
            multiple = TRUE, choices = sort(setdiff(ach_profile$District, input$district)),
            selected = "State of Tennessee", options = list(maxItems = 7))
    })

    tooltip <- function(x) {
        row <- ach_profile[ach_profile$District == x$District, ]

        paste0("<b>", row$District, "</b><br>",
            names(outcome_list)[outcome_list == input$outcome], ": ",
            row[names(row) == input$outcome])
    }

    # Current year plot
    plot <- reactive({

        # Label for vertical axis
        yvar_name <- names(outcome_list[outcome_list == input$outcome])

        # Convert subject input (string) to variable name
        yvar <- prop("y", as.symbol(input$outcome))

        # Scale vertical axis to [0, 100] if outcome is a % P/A, otherwise, scale to min/max of variable
        if (grepl("Percent Proficient or Advanced", yvar_name)) {
            y_scale <- c(0, 100)
        } else if (yvar_name == "Average ACT Composite Score") {
            y_scale <- c(0, 36)
        } else {
            y_scale <- c(floor(min(ach_profile[names(ach_profile) == input$outcome])),
                ceiling(max(ach_profile[names(ach_profile) == input$outcome])))
        }

        ach_profile %>%
            filter(District %in% c(input$district, input$comparison)) %>%
            ggvis(~District, yvar, key := ~District) %>%
            layer_bars(fill := "blue", fillOpacity := 0.3, fillOpacity.hover := 0.9) %>%
            add_axis("x", title = "District", grid = FALSE) %>%
            add_axis("y", title = yvar_name, grid = FALSE) %>%
            add_tooltip(tooltip, on = "hover") %>%
            scale_ordinal("x", domain = c(input$district, input$comparison)) %>%
            scale_numeric("y", domain = y_scale, expand = 0) %>%
            scale_numeric("opacity", range = c(0.3, 0.9)) %>%
            set_options(width = "auto", height = 500)

    })

    plot %>% bind_shiny("plot")

    # Tooltip for historical data plot
    tooltip_historical <- function(x) {
        row <- historical[historical$District == x$District & historical$subject == input$outcome & historical$year == x$year, ]

        paste0("<b>", row$District, "</b><br>",
            row$year, " ", names(outcome_list)[outcome_list == input$outcome], ": ", row$pct_prof_adv)
    }

    # Historical plot
    historical_plot <- reactive({

        # Label for vertical axis
        yvar_name <- names(outcome_list[outcome_list == input$outcome])

        historical %>%
            filter(District %in% c(input$district, input$comparison)) %>%
            filter(subject == input$outcome) %>%
            ggvis(~year, ~pct_prof_adv, stroke = ~District) %>%
            layer_points(fill = ~District) %>%
            layer_lines() %>%
            add_axis("x", title = "Year", grid = FALSE, values = 2011:2015, format = "d") %>%
            add_axis("y", title = yvar_name, grid = FALSE) %>%
            add_tooltip(tooltip_historical, on = "hover") %>%
            scale_ordinal("fill", domain = c(input$district, input$comparison)) %>%
            scale_ordinal("stroke", domain = c(input$district, input$comparison)) %>%
            set_options(width = "auto", height = 500, renderer = "canvas")

    })

    historical_plot %>% bind_shiny("historical_plot")

    }
)
