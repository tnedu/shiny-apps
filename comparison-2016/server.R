## District Comparison Tool
# server.R

shinyServer(function(input, output) {

    # Disable inputs and show message if no district or characteristics are selected
    observe(
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
    )

    # Hide "Go!" button after first use
    observe(
        if (input$button >= 1) {
            hide(id = "button")
            show(id = "info")
        }
    )

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
               ..f = ~ sqrt(sum((.x[input$district_chars] -
                    chars_std[which(chars_std$District == input$district), input$district_chars])^2)),
               .to = "Score", .collate = "cols") %>%
            mutate(Selected = (District == input$district)) %>%
            filter(!is.na(Score)) %>%
            arrange(desc(Selected), Score) %>%
            slice(1:(input$num_districts + 1))

    })

    output$header_plot <- renderText(
        paste(names(outcome_list[outcome_list == input$outcome]),
            "for districts most similar to", input$district)
    )

    # Outcome plot
    output$plot <- renderRbokeh({

        if (all(is.na(similarity()[input$outcome]))) return()

        y_range <- switch(input$outcome,
            "ACT English" = , "ACT Math" = , "ACT Reading" =, "ACT Science" = ,
            "ACT Composite" = c(1, 36),
            "Chronic Absence" = c(0, 45),
            "Dropout" = c(0, 30),
            "Suspension" = c(0, 25),
            "Expulsion" = c(0, 2),
            c(0, 100)
        )

        figure(data = similarity(), xlab = "", ylab = names(outcome_list[outcome_list == input$outcome]),
               xlim = similarity()$District, ylim = y_range,
               padding_factor = 0, xgrid = FALSE,
               tools = "save", toolbar_location = "above") %>%
            ly_bar(x = "District", y = input$outcome, hover = TRUE)

    })

    output$header_table <- renderText(
        paste("Profile data for", input$district, "and most similar districts")
    )

    # Table with profile data for selected and comparison districts
    output$table <- renderTable(striped = TRUE, {

        comp_table <- similarity() %>%
            select(Year, District) %>%
            inner_join(ach_profile, by = c("Year", "District")) %>%
            select(District, Enrollment:Expenditures) %>%
            rename(`Percent Black` = Black,
                `Percent Hispanic` = Hispanic,
                `Percent Native American` = Native,
                `Percent Economically Disadvantaged` = ED,
                `Percent English Learners` = EL,
                `Percent Students with Disabilities` = SWD,
                `Per-Pupil Expenditures` = Expenditures) %>%
            gather(Characteristic, Value, Enrollment:`Per-Pupil Expenditures`) %>%
            spread(District, Value)

        row_order <- c("Enrollment", "Per-Pupil Expenditures", "Percent Economically Disadvantaged", "Percent Students with Disabilities",
            "Percent English Learners", "Percent Black", "Percent Hispanic", "Percent Native American")
        comp_table <- comp_table[match(row_order, comp_table$Characteristic), ]

        # Format table with $, %
        comp_table[2, -1] <- sprintf("$%.2f", comp_table[2, -1])
        comp_table[3, -1] <- sprintf("%.1f%%", comp_table[3, -1])
        comp_table[4, -1] <- sprintf("%.1f%%", comp_table[4, -1])
        comp_table[5, -1] <- sprintf("%.1f%%", comp_table[5, -1])
        comp_table[6, -1] <- sprintf("%.1f%%", comp_table[6, -1])
        comp_table[7, -1] <- sprintf("%.1f%%", comp_table[7, -1])
        comp_table[8, -1] <- sprintf("%.1f%%", comp_table[8, -1])

        # Order columns by similarity
        comp_table[c("Characteristic", similarity()$District)]

    })

})
