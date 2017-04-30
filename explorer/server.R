## District Explorer
# server.R

shinyServer(function(input, output) {

    # Filter data based on selected year and highlight selected district
    filtered <- reactive({

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
                "TVAAS Literacy" = ,
                "TVAAS Numeracy" = ,
                "TVAAS Science" = ,
                "TVAAS Social Studies" = ,
                "TVAAS Composite" = c("#d62728", "#ff9896", "#98df8a", "#aec7e8", "#1f77b4", "#7f7f7f"),
                "#1f77b4")

        if (input$color == "") {
            tooltip_content <- c("District", input$char, input$outcome)
        } else {
            tooltip_content <- c("District", input$char, input$outcome, input$color)
        }

        p <- figure(data = filtered(), padding_factor = 0.04,
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

    filter_map <- reactive({

        req(input$map_var)

        # Make reactive with respect to input$var
        var <- ach_profile %>%
            filter(Year == input$year2,
                !(System %in% c(0, 793:798, 960, 961, 963, 964, 970, 985))) %>%
            mutate(District = if_else(District == "Davidson County" , "Nashville-Davidson County", District)) %>%
            arrange(District) %>%
            magrittr::extract2(input$map_var)

        tennessee$variable <- var

        return(tennessee)

    })

    output$map <- renderLeaflet({

        leaflet() %>%
            addTiles() %>%
            fitBounds(lng1 = -90.19, lat1 = 36.41, lng2 = -81.39, lat2 = 34.59)

    })

    observe({

        tooltip <- paste0(tennessee$NAME, "<br/>",
                input$map_var, ": ", filter_map()$variable) %>%
            lapply(HTML)

        pal <- colorQuantile("YlGnBu", domain = filter_map()$variable, n = 5)

        withProgress(message = "Rendering...", {

            leafletProxy("map", data = filter_map()) %>%
                clearShapes() %>%
                addPolygons(color = "#444444", weight = 1, smoothFactor = 0.5,
                    opacity = 1, fillOpacity = 0.6, fillColor = ~pal(variable),
                    highlightOptions = highlightOptions(color = "white", weight = 2, bringToFront = TRUE),
                    label = tooltip) %>%
                clearControls() %>%
                addLegend(position = "bottomright", title = paste(input$map_var, "Percentile"),
                    pal = pal, values = ~variable, opacity = 1)

            incProgress(1)

        })
    })

    output$table <- DT::renderDataTable({

        req(input$table_vars)

        ach_profile %>%
            select(Year, District, one_of(input$table_vars)) %>%
            DT::datatable(rownames = FALSE, filter = "top", options = list(pageLength = 147))

    })

    output$downloadData <- downloadHandler(
        filename = "achievement_profile_data_2015_2016.csv",
        content = function(file) {
            write_csv(ach_profile, file, na = "")
        }
    )

})
