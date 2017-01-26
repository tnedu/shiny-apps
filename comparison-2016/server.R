## District Comparison Tool
# server.R

shinyServer(function(input, output) {

    # Hide output, disable inputs, and show message if no district characteristics are selected
    observe({
        if (length(input$district_chars) == 0) {
            hide(id = "output")
            show(id = "request_input")
            disable(id = "outcome")
            disable(id = "year")
            disable(id = "num_districts")
            disable(id = "restrict_CORE")
        } else {
            show(id = "output")
            hide(id = "request_input")
            enable(id = "outcome")
            enable(id = "year")
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
        similarity <- data_frame(District = chars$District, similarity_score = NA)

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

    output$header <- renderText({paste(names(outcome_list[outcome_list == input$outcome]),
        "for districts most similar to", input$district, sep = " ")})

    # Drop comparison columns/dots when input district changes
    observe({
        clicked$district <- input$district
    })

})
