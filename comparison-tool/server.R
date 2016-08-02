## District Comparison Tool
# server.R

shinyServer(function(input, output) {

    # Hide output and show message if no district characteristics are selected
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

    ## Main outcome output
    # Identify most similar districts based on selected characteristics
    similarityData <- reactive({

        # Narrow comparison to within CORE region if specified
        if (input$restrict_CORE) {
            filter_region <- df_std[df_std$system_name == input$district, ]$CORE_region
            df_std <- filter(df_std, CORE_region == filter_region)
        }

        # Ensure that app doesn't crash if no characteristics are selected
        req(input$district_chars)

        chars <- select(df_std, one_of(c("system_name", input$district_chars)))

        # Compute similarity scores against selected district
        similarity <- data.frame(system_name = chars[, 1], similarity_score = NA, stringsAsFactors = FALSE)

        for (i in 1:nrow(chars)) {
            similarity[i, 2] <- sqrt(sum((chars[i,2:ncol(chars)] - chars[which(chars$system_name == input$district), 2:ncol(chars)])^2))
        }

        # Select 8 most similar districts
        similarity %>%
            mutate("Selected" = (system_name == input$district),
                "Opacity" = ifelse(system_name %in% c(input$district, clicked$district), 0.9, 0.3)) %>%
            arrange(desc(Selected), similarity_score) %>%
            inner_join(df_outcomes, by = "system_name") %>%
            slice(1:(1 + input$num_districts))

    })

    # Tooltip for bar graph with district name and proficiency %
    tooltip_bar <- function(x) {
        if (is.null(x)) return(NULL)
        row <- df[df$system_name == x$system_name, ]

        paste0("<b>", row$system_name, "</b><br>",
            names(outcome_list)[outcome_list == input$outcome], ": ",
            row[names(row) == input$outcome])
    }

    # Extract clicked district for secondary table
    clicked <- reactiveValues(district = "")
    click_district <- function(data, ...) {
        clicked$district <- as.character(data$system_name)
    }

    # Column chart of proficiency for selected, similar districts
    plot_prof <- reactive({

        # Label for vertical axis
        yvar_name <- names(outcome_list[outcome_list == input$outcome])

        # Convert subject input (string) to variable name
        yvar <- prop("y", as.symbol(input$outcome))

        # Scale vertical axis to [0, 100] if outcome is a % P/A, otherwise, scale to min/max of variable
        if (grepl("Percent Proficient or Advanced", yvar_name)) {
            y_scale <- c(0, 100)
        } else {
            y_scale <- c(floor(min(df_outcomes[names(df_outcomes) == input$outcome])), 
                ceiling(max(df_outcomes[names(df_outcomes) == input$outcome])))
        }

        similarityData() %>%
            ggvis(~system_name, yvar, key := ~system_name) %>%
            layer_bars(fill := "blue", width = 0.85, fillOpacity = ~Opacity, fillOpacity.hover := 0.9) %>%
            add_axis("x", title = "District", grid = FALSE) %>%
            add_axis("y", title = yvar_name, grid = FALSE) %>%
            add_tooltip(tooltip_bar, on = "hover") %>%
            scale_ordinal("x", domain = similarityData()$system_name) %>%
            scale_numeric("y", domain = y_scale, expand = 0) %>%
            scale_numeric("opacity", range = c(0.3, 0.9)) %>%
            set_options(width = 'auto', height = 600) %>%
            hide_legend("fill") %>%
            handle_click(click_district)

    })

    plot_prof %>% bind_shiny("plot_prof")

    output$header_bar <- renderText({paste(names(outcome_list[outcome_list == input$outcome]), 
        "for districts most similar to", input$district, sep = " ")})

    # Line graph with historical data
    plot_hist <- reactive({

        # Label for vertical axis
        yvar_name <- names(outcome_list[outcome_list == input$outcome])

        historical %>%
            filter(subject == input$outcome) %>%
            filter(District %in% similarityData()$system_name) %>%
            ggvis(~factor(year), ~pct_prof_adv, stroke = ~District) %>%
            layer_points(fill = ~District) %>%
            layer_lines() %>%
            add_axis("x", title = "Year", grid = FALSE) %>%
            add_axis("y", title = yvar_name, grid = FALSE) %>%
            scale_numeric("y", domain = c(0, 100), expand = 0) %>%
            set_options(width = 'auto', height = 600)
    })

    plot_hist %>% bind_shiny("plot_hist")

    ## Secondary profile output
    # Tooltip for scatterplot with district name and profile data
    tooltip_scatter <- function(x) {
        if (is.null(x)) return(NULL)
            row <- df_chars[df_chars$system_name == x$District, ]

            paste0("<b>", row$system_name, "</b><br>", 
                x$Characteristic, ": ", row[names(row) == x$Characteristic], "<br>",
                x$Characteristic, " Percentile: ", x$Value)
    }

    # Scatterplot of percentile ranks for district characteristics
    plot_char <- reactive({

        df_pctile %>%
            filter(District == input$district | District == clicked$district) %>%
            gather("Characteristic", "Value", 2:9) %>%
            mutate(Value = round(100 * Value, 1)) %>%
            ggvis(~Value, ~Characteristic) %>%
            layer_points(fill = ~District, size := 125, opacity := 0.5, opacity.hover := 0.9) %>%
            add_axis("x", title = "Percentile", grid = FALSE) %>%
            add_axis("y", title = "") %>%
            add_tooltip(tooltip_scatter, on = "hover") %>%
            scale_numeric("x", domain = c(0, 100), expand = 0) %>%
            scale_ordinal("y", domain = c("Enrollment", "Per-Pupil Expenditures", 
                "Percent Economically Disadvantaged", "Percent Students with Disabilities",
                "Percent English Learners", "Percent Black", "Percent Hispanic", "Percent Native American")) %>%
            set_options(width = 'auto', height = 400)

    })

    plot_char %>% bind_shiny("plot_char")

    # Table with profile data for selected, clicked districts
    output$table <- renderFlexTable({
    
        df_comparison <- df_chars %>%
            select(system_name, Enrollment, `Percent Black`, `Percent Hispanic`, `Percent Native American`,
                `Percent Economically Disadvantaged`, `Percent Students with Disabilities`,
                `Percent English Learners`, `Per-Pupil Expenditures`) %>%
            filter(system_name == input$district | system_name == clicked$district) %>%
            gather("Characteristic", "value", 2:9) %>%
            spread("system_name", "value")

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

        comp_table <- FlexTable(df_comparison, header.par.props = parProperties(text.align = "center"), body.par.props = parProperties(text.align = "center"))

        options("ReporteRs-default-font" = "Open Sans")

        # Add conditional formatting to highlight large differences
        if (ncol(df_comparison) == 4) {
            setFlexTableWidths(comp_table, widths = c(4, 3, 3, 3))

            format_FlexTable <- function(char) {
                comp_table[df_comparison$Characteristic == char & abs(df_comparison$Difference) >= as.numeric(standard_devs[names(standard_devs) == char]), 4] = 
                    chprop(cellProperties(), background.color = "orange")
                comp_table[df_comparison$Characteristic == char & abs(df_comparison$Difference) >= 0.5 * as.numeric(standard_devs[names(standard_devs) == char]) & 
                    abs(df_comparison$Difference) < as.numeric(standard_devs[names(standard_devs) == char]), 4] = chprop(cellProperties(), background.color = "yellow")
            }

            for (char in row_order) {
                format_FlexTable(char)
            }
        } else {
            setFlexTableWidths(comp_table, widths = c(4, 3))
        }

        return(comp_table)

    })

    output$header_comp <- renderText({
        if (clicked$district == "" | clicked$district == input$district) {
            paste("District Profile Data for", input$district, sep = " ")
        } else {
            paste("District Profile Data for", input$district, "and", clicked$district, sep = " ")
        }
    })

    # Drop comparison columns/dots when input district changes
    observe({
        clicked$district <- input$district
    })

})