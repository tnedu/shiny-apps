## District Comparison Tool
# server.R

shinyServer(function(input, output) {

    # Hide output, disable inputs, and show message if no district characteristics are selected
    observe({
        if (length(input$district_chars) == 0) {
            hide(id = "output")
            show(id = "request_input")
            disable(id = "outcome")
            disable(id = "num_districts")
            disable(id = "restrict_CORE")
        } else {
            show(id = "output")
            hide(id = "request_input")
            enable(id = "outcome")
            enable(id = "num_districts")
            enable(id = "restrict_CORE")
        }
    })

    # Hide "Go!" button after first use
    observe({
        if (input$button >= 1) {
            hide(id = "button")
            show(id = "info")
        }
    })

    ## Main outcome output
    # Identify most similar districts based on selected characteristics
    similarityData <- reactive({

        # Ensure that app doesn't crash if no characteristics are selected
        req(input$district_chars)

        # Narrow comparison within CORE region if specified
        if (input$restrict_CORE) {
            filter_region <- chars_std[chars_std$District == input$district, ]$Region
            chars_std <- filter(chars_std, Region == filter_region)
        }

        chars <- select(chars_std, one_of(c("District", input$district_chars)))

        # Compute similarity scores against selected district
        similarity <- data.frame(District = chars[, 1], similarity_score = NA, stringsAsFactors = FALSE)

        for (i in 1:nrow(chars)) {
            similarity[i, 2] <- sqrt(sum((chars[i, 2:ncol(chars)] - chars[which(chars$District == input$district), 2:ncol(chars)])^2))
        }

        # Select 8 most similar districts
        similarity %>%
            mutate(Selected = (District == input$district),
                Highlighted = ifelse(District %in% c(input$district, clicked$district), 1, 0)) %>%
            arrange(desc(Selected), similarity_score) %>%
            inner_join(outcomes, by = "District") %>%
            slice(1:(1 + input$num_districts))

    })

    # Tooltip for bar graph with district name and proficiency %
    tooltip_bar <- function(x) {
        row <- ach_profile[ach_profile$District == x$District, ]

        paste0("<b>", row$District, "</b><br>",
            names(outcome_list)[outcome_list == input$outcome], ": ", 
            row[names(row) == input$outcome])
    }

    # Extract clicked district for secondary table from bar graph
    clicked <- reactiveValues(district = "")
    click_bar <- function(data, ...) {
        clicked$district <- data$District
    }

    # Bar graph of outcome for selected, similar districts
    plot_outcome <- reactive({

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
            y_scale <- c(floor(min(outcomes[names(outcomes) == input$outcome])),
                ceiling(max(outcomes[names(outcomes) == input$outcome])))
        }

        similarityData() %>%
            ggvis(~District, yvar, key := ~District) %>%
            layer_bars(fill := "blue", width = 0.8, fillOpacity = ~Highlighted, fillOpacity.hover := 0.9) %>%
            add_axis("x", title = "District", grid = FALSE) %>%
            add_axis("y", title = yvar_name, grid = FALSE) %>%
            add_tooltip(tooltip_bar, on = "hover") %>%
            scale_ordinal("x", domain = similarityData()$District) %>%
            scale_numeric("y", domain = y_scale, expand = 0) %>%
            scale_numeric("opacity", range = c(0.3, 0.9)) %>%
            set_options(width = "auto", height = 600) %>%
            hide_legend("fill") %>%
            handle_click(click_bar)

    })

    plot_outcome %>% bind_shiny("plot_outcome")

    output$header_bar <- renderText({paste(names(outcome_list[outcome_list == input$outcome]),
        "for districts most similar to", input$district, sep = " ")})

    # Tooltip for historical data plot
    tooltip_historical <- function(x) {
        row <- historical[historical$District == x$District & historical$Subject == input$outcome & historical$Year == x$Year, ]

        paste0("<b>", row$District, "</b><br>",
            row$Year, " ", names(outcome_list)[outcome_list == input$outcome], ": ", row$`Percent P/A`)
    }

    # Extract clicked district for secondary table from line graph
    click_line <- function(data, ...) {
        clicked$district <- data$District
    }

    # Line graph with historical data
    plot_hist <- reactive({

        # Label for vertical axis
        yvar_name <- names(outcome_list[outcome_list == input$outcome])

        historical %>%
            mutate(Opacity = ifelse(District %in% c(input$district, clicked$district), 1, 0.3)) %>%
            filter(Subject == input$outcome) %>%
            inner_join(similarityData(), by = "District") %>%
            ggvis(~Year, ~`Percent P/A`, stroke = ~District, opacity = ~Opacity, opacity.hover := 0.9) %>%
            layer_points(fill = ~District, size := 100) %>%
            layer_lines() %>%
            add_axis("x", grid = FALSE, values = 2011:2015, format = "d") %>%
            add_axis("y", title = yvar_name, grid = FALSE) %>%
            add_tooltip(tooltip_historical, on = "hover") %>%
            scale_ordinal("fill", domain = similarityData()$District) %>%
            scale_ordinal("stroke", domain = similarityData()$District) %>%
            scale_numeric("opacity", range = c(0.3, 1)) %>%
            set_options(width = "auto", height = 600, renderer = "canvas") %>%
            handle_click(click_line)
    })

    plot_hist %>% bind_shiny("plot_hist")

    ## Secondary profile output
    # Table with profile data for selected, clicked districts
    output$table_profile <- renderFlexTable({

        df_comparison <- chars %>%
            select(District:`Per-Pupil Expenditures`) %>%
            filter(District %in% c(input$district, clicked$district)) %>%
            gather(Characteristic, value, 2:9) %>%
            spread(District, value)

        if (clicked$district != "" & clicked$district != input$district) {
            # Specify column order for table
            df_comparison <- df_comparison[c("Characteristic", input$district, clicked$district)]

            # Create new column with differences between selected, clicked districts
            df_comparison$Difference <- df_comparison[[3]] - df_comparison[[2]]
        }

        # Specify row order for table
        row_order <- c("Enrollment", "Per-Pupil Expenditures", "Percent Economically Disadvantaged", "Percent Students with Disabilities",
            "Percent English Learners", "Percent Black", "Percent Hispanic", "Percent Native American")
        df_comparison <- df_comparison[match(row_order, df_comparison$Characteristic), ]

        # Format table with $, %
        df_comparison[2, -1] <- paste0("$", sprintf("%.2f", df_comparison[2, -1]))
        df_comparison[3, -1] <- paste0(sprintf("%.1f", df_comparison[3, -1]), "%")
        df_comparison[4, -1] <- paste0(sprintf("%.1f", df_comparison[4, -1]), "%")
        df_comparison[5, -1] <- paste0(sprintf("%.1f", df_comparison[5, -1]), "%")
        df_comparison[6, -1] <- paste0(sprintf("%.1f", df_comparison[6, -1]), "%")
        df_comparison[7, -1] <- paste0(sprintf("%.1f", df_comparison[7, -1]), "%")
        df_comparison[8, -1] <- paste0(sprintf("%.1f", df_comparison[8, -1]), "%")

        comp_table <- FlexTable(df_comparison, header.par.props = parProperties(text.align = "center"), body.par.props = parProperties(text.align = "center"))

        options("ReporteRs-default-font" = "Open Sans")

        # Set table widths
        if (ncol(df_comparison) == 4) {
            setFlexTableWidths(comp_table, widths = c(4, 3, 3, 3))
        } else {
            setFlexTableWidths(comp_table, widths = c(4, 3))
        }

        return(comp_table)

    })

    output$header_comp <- renderText({

        if (clicked$district %in% c("", input$district)) {
            paste("District Profile Data for", input$district)
        } else {
            paste("District Profile Data for", input$district, "and", clicked$district)
        }

    })

    # Drop comparison columns/dots when input district changes
    observe({
        clicked$district <- input$district
    })

})
