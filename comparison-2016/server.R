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
                   Highlighted = ifelse(District == input$district, 1, 0)) %>%
            arrange(desc(Selected), similarity_score) %>%
            inner_join(outcomes, by = "District") %>%
            slice(1:(1 + input$num_districts))

    })

    output$header <- renderText({paste(names(outcome_list[outcome_list == input$outcome]),
        "for districts most similar to", input$district, sep = " ")})

    # Outcome plot
    output$plot_bokeh <- renderRbokeh({

        if (mean(is.na(similarityData()[input$outcome])) == 1) return()

        figure(data = similarityData(), xlim = similarityData()$District,
               padding_factor = 0) %>%
            ly_bar(x = "District", y = input$outcome, hover = TRUE)

    })

})
