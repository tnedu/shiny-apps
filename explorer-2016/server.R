## District Data Explorer
# server.R

shinyServer(function(input, output, session) {

    # Filter data based on selected year and highlight selected district
    filtered <- reactive({

        temp <- ach_profile %>%
            filter(Year == input$year) %>%
            mutate(Selected = 1)

        if (input$highlight != "") {
            mutate(temp, Selected = ifelse(District == input$highlight, 1, 0.3))
        } else {
            return(temp)
        }

    })

    output$scatter <- renderRbokeh({

        color_palette <- switch(input$color,
            "Accountability Status 2015" = c("#1f77b4", "#d62728", "#ff7f0e", "#2ca02c", "#7f7f7f"),
            "Region" = c("#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9476bd", "#8c564b", "#e377c2", "#7f7f7f", "#bcbd22"),
            "TVAAS Literacy" = ,
            "TVAAS Numeracy" = ,
            "TVAAS Science" = ,
            "TVAAS Social Studies" = ,
            "TVAAS Composite" = c("#d62728", "#ff9896", "#98df8a", "#aec7e8", "#1f77b4", "#7f7f7f"),
            "#1f77b4"
        )

        if (input$color != "") {
            tooltip_content <- c("District", input$char, input$outcome, input$color)
        } else {
            tooltip_content <- c("District", input$char, input$outcome)
        }

        p <- figure(data = filtered(), padding_factor = 0.04,
                xlab = names(chars[chars == input$char]),
                ylab = names(outcomes[outcomes == input$outcome]),
                toolbar_location = "above", legend_location = NULL) %>%
            ly_points(x = input$char, y = input$outcome, alpha = Selected,
                color = input$color, hover = tooltip_content, lname = "points") %>%
            set_palette(discrete_color = pal_color(color_palette))

        if (input$char == "Enrollment") {
            x_axis(p, log = TRUE)
        } else {
            return(p)
        }

    })

    output$map <- renderLeaflet(
        leaflet() %>%
            addTiles() %>%
            addMarkers(
                lng = geocode[geocode$District == input$highlight, ]$Longitude,
                lat = geocode[geocode$District == input$highlight, ]$Latitude,
                popup = paste(sep = "<br/>",
                    paste0("<b>", geocode[geocode$District == input$highlight, ]$`District Name`, "</b>"),
                    geocode[geocode$District == input$highlight, ]$Address,
                    geocode[geocode$District == input$highlight, ]$City
                )
            )
    )

    output$district_info <- renderText(
        paste("<b>District Name:", geocode[geocode$District == input$highlight, ]$`District Name`, "</b><br/>",
        "<br/>",
        "Grades Served:", filtered()[filtered()$District == input$highlight, ]$`Grades Served`, "<br/>",
        "Number of Schools:",filtered()[filtered()$District == input$highlight, ]$`Number of Schools`, "<br/>",
        "<br/>",
        "Percent Black/Hispanic/Native American Students:", filtered()[filtered()$District == input$highlight, ]$BHN, "<br/>",
        "Percent Economically Disadvantaged Students:", filtered()[filtered()$District == input$highlight, ]$ED, "<br/>",
        "Percent Students with Disabilities:", filtered()[filtered()$District == input$highlight, ]$SWD, "<br/>",
        "Percent English Learners:", filtered()[filtered()$District == input$highlight, ]$EL)
    )

    output$prof <- renderRbokeh({

        # Ensure consistent bar colors
        if (input$highlight < "State of Tennessee") {
            color_palette <- c("#1f77b4", "#d62728")
        } else {
            color_palette <- c("#d62728", "#1f77b4")
        }

        long <- filtered() %>%
            filter(District %in% c(input$highlight, "State of Tennessee")) %>%
            mutate(District = factor(District, levels = c(input$highlight, "State of Tennessee"))) %>%
            select(District, ELA:`US History`) %>%
            gather(Subject, Value, -District) %>%
            group_by(Subject) %>%
            mutate(Count = sum(!is.na(Value))) %>%
            filter(Count == 2)

        # Don't render plot if district has no data
        if (nrow(long) == 0) return()

        figure(xlab = "", ylab = "Percent On Track/Mastered",
               padding_factor = 0, tools = "save") %>%
            ly_bar(x = Subject, y = Value, data = long, hover = TRUE,
                color = District, position = "dodge") %>%
            y_range(c(0, 100)) %>%
            set_palette(discrete_color = pal_color(color_palette))

    })

    output$tvaas_table <- renderTable(
        filtered() %>%
            filter(District == input$highlight) %>%
            select(contains("TVAAS"))
    )

    output$grad_chart <- renderRbokeh({

        # Ensure consistent bar colors
        if (input$highlight < "State of Tennessee") {
            color_palette <- c("#1f77b4", "#d62728")
        } else {
            color_palette <- c("#d62728", "#1f77b4")
        }

        long <- filtered() %>%
            filter(District %in% c(input$highlight, "State of Tennessee")) %>%
            mutate(District = factor(District, levels = c(input$highlight, "State of Tennessee"))) %>%
            select(District, Grad, `ACT 21 or Above`) %>%
            rename(`Graduation Rate` = Grad) %>%
            gather(Subject, Value, -District) %>%
            group_by(Subject) %>%
            mutate(Count = sum(!is.na(Value))) %>%
            filter(Count == 2)

        # Don't render plot if district has no data
        if (nrow(long) == 0) return()

        figure(xlab = "", ylab = "Percent", xlim = c("Graduation Rate", "ACT 21 or Above"),
               padding_factor = 0, tools = "save") %>%
            ly_bar(x = Subject, y = Value, data = long, hover = TRUE,
                   color = District, position = "dodge") %>%
            y_range(c(0, 100)) %>%
            set_palette(discrete_color = pal_color(color_palette))

    })

    output$downloadData <- downloadHandler(
        filename = "achievement_profile_data_2015_2016.csv",
        content = function(file) {
            write_csv(ach_profile, file, na = "")
        }
    )

    output$report <- downloadHandler(
        filename = paste(input$highlight, "Report.docx"),
        content = function(file) {
            tempReport <- file.path(tempdir(), paste(input$highlight, "report.Rmd"))
            file.copy("report.Rmd", tempReport, overwrite = TRUE)

            rmarkdown::render(tempReport, output_file = file,
                params = list(district = input$highlight, year = input$year),
                envir = new.env(parent = globalenv()))
        }
    )

})
