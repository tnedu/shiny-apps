## District Explorer
# server.R

function(input, output) {

    # Filter data based on year and highlight selected district
    filter_plot <- reactive({

        temp <- ach_profile %>%
            filter(Year == input$year) %>%
            mutate(Selected = 1)

        if (input$highlight != "") {
            mutate(temp, Selected = if_else(District == input$highlight, 1, 0.3))
        } else {
            return(temp)
        }

    })

    output$scatter <- renderRbokeh({

        color_palette <- switch(input$color,
            "Accountability Status 2015" = c("#1f77b4", "#d62728", "#ff7f0e", "#2ca02c", "#7f7f7f"),
            "Region" = c("#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9476bd", "#8c564b", "#e377c2", "#7f7f7f", "#bcbd22"),
            "TVAAS Literacy" = , "TVAAS Numeracy" = , "TVAAS Science" = , "TVAAS Social Studies" = ,
            "TVAAS Composite" = c("#d62728", "#ff9896", "#98df8a", "#aec7e8", "#1f77b4", "#7f7f7f"),
            "#1f77b4")

        tooltip_content <- c("District", input$char, input$outcome)

        # Conditionally add color variable to tooltip
        if (input$color != "") tooltip_content <- c(tooltip_content, input$color)

        p <- figure(data = filter_plot(), padding_factor = 0.04,
                xlab = names(chars[chars == input$char]),
                ylab = input$outcome,
                toolbar_location = "above", legend_location = NULL) %>%
            ly_points(x = input$char, y = input$outcome, alpha = Selected,
                color = input$color, hover = tooltip_content) %>%
            set_palette(discrete_color = pal_color(color_palette))

        if (input$char == "Enrollment") {
            x_axis(p, log = TRUE)
        } else {
            return(p)
        }

    })

    # Draw baseline map
    output$map <- renderLeaflet(
        leaflet() %>%
            addTiles() %>%
            fitBounds(lng1 = -90, lat1 = 37, lng2 = -81, lat2 = 34)
    )

    # Filter data for map
    filter_map <- reactive({

        req(input$map_var)

        var <- ach_profile %>%
            filter(Year == input$year_map,
            # Drop districts without polygons
                !(System %in% c(0, 793:798, 960, 961, 963, 964, 970, 985))) %>%
            mutate(District = if_else(District == "Davidson County", "Nashville-Davidson County", District)) %>%
            arrange(District) %>%
            magrittr::extract2(input$map_var)

        tennessee$variable <- var

        return(tennessee)

    })

    # Update polygons
    observe({

        tooltip <- paste0(tennessee$NAME, "<br/>",
                input$map_var, ": ", filter_map()$variable) %>%
            lapply(HTML)

        pal <- colorQuantile("YlGnBu", domain = filter_map()$variable, n = 5)

        withProgress(message = "Rendering...", {

            leafletProxy("map", data = filter_map()) %>%
                clearShapes() %>%
                addPolygons(color = "#444444", weight = 1, opacity = 1,
                    fillOpacity = 0.6, fillColor = ~pal(variable), label = tooltip,
                    highlightOptions = highlightOptions(color = "white", weight = 2, bringToFront = TRUE)) %>%
                clearControls() %>%
                addLegend(position = "bottomright", opacity = 1, title = input$map_var,
                    color = c("#ffffcc", "#a1dab4", "#41b6c4", "#2c7fb8", "#253494"),
                    labels = c("Lower", "", "", "", "Higher"))

            incProgress(1)

        })

    })

    # Datatable with raw data
    output$table <- DT::renderDataTable({

        req(input$table_vars)

        ach_profile %>%
            select(Year, District, one_of(input$table_vars)) %>%
            mutate(Year = factor(Year)) %>%
            DT::datatable(rownames = FALSE, filter = "top", options = list(pageLength = 147))

    })

    output$downloadData <- downloadHandler(
        filename = "achievement_profile_data_2015_2016.csv",
        content = function(file) write_csv(ach_profile, file, na = "")
    )

}
