## District Comparison Tool
# server.R

shinyServer(function(input, output) {

    # Disable inputs and show message if no characteristics are selected
    observe({
        if (length(input$district_chars) == 0 | input$district == "") {
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
    similarity <- reactive({

        # Ensure that app doesn't crash if no characteristics are selected
        req(input$district, input$district_chars)

        chars_std <- ach_profile %>%
            filter(Year == input$year) %>%
            mutate_each(funs(scale), Enrollment:Expenditures)

        # Narrow comparison within CORE region if specified
        if (input$restrict_CORE) {
            filter_region <- chars_std[chars_std$District == input$district, ]$Region
            chars_std <- filter(chars_std, Region == filter_region)
        }

        # Calculate similarity scores
        by_row(.d = chars_std,
               ..f = ~ sqrt(sum((.x[c(input$district_chars)] -
                    chars_std[which(chars_std$District == input$district), c(input$district_chars)])^2)),
               .to = "Score", .collate = "cols") %>%
            mutate(Selected = (District == input$district)) %>%
            filter(!is.na(Score)) %>%
            arrange(desc(Selected), Score) %>%
            slice(1:(input$num_districts + 1))

    })

    output$header <- renderText({paste(names(outcome_list[outcome_list == input$outcome]),
        "for districts most similar to", input$district)})

    # Outcome plot
    output$plot_bokeh <- renderRbokeh({

        if (all(is.na(similarity()[input$outcome]))) return()

        figure(data = similarity(), xlim = similarity()$District,
                padding_factor = 0) %>%
            ly_bar(x = "District", y = input$outcome, hover = TRUE)

    })

})
