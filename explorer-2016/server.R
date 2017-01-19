shinyServer(function(input, output) {

    output$scatter <- renderRbokeh({

        p <- figure(toolbar_location = "above", legend_location = NULL)

        if (input$color == "") {
            ly_points(p, x = input$char, y = input$outcome, data = ach_profile[ach_profile$Year == input$year, ],
                hover = c("District", input$char, input$outcome), lname = "points") %>%
            tool_tap(shiny_callback("tap_info"), "points")
        } else if (grepl("TVAAS", input$color)) {
            ly_points(p, x = input$char, y = input$outcome, data = ach_profile[ach_profile$Year == input$year, ],
                color = input$color, hover = c("District", input$char, input$outcome, input$color), lname = "points") %>%
            set_palette(discrete_color = pal_color(c("#d7191c", "#fdae61", "#ffffbf", "#abdda4", "#2b83ba"))) %>%
            tool_tap(shiny_callback("tap_info"), "points")
        } else if (input$color == "Accountability 2015") {
            ly_points(p, x = input$char, y = input$outcome, data = ach_profile[ach_profile$Year == input$year, ],
                      color = input$color, hover = c("District", input$char, input$outcome, input$color), lname = "points") %>%
                set_palette(discrete_color = pal_color(c("#1f77b4", "#d62728", "#ff7f0e", "#2ca02c", "#7f7f7f"))) %>%
                tool_tap(shiny_callback("tap_info"), "points")
        } else {
            ly_points(p, x = input$char, y = input$outcome, data = ach_profile[ach_profile$Year == input$year, ],
                color = input$color, hover = c("District", input$char, input$outcome, input$color), lname = "points") %>%
            tool_tap(shiny_callback("tap_info"), "points")
        }
    })


    # Take only one value in case multiple points are clicked
    values <- reactiveValues(clicked = "")

    observe({
        values$clicked <- ach_profile[input$tap_info + 1, ]$District[1]
    })

    output$map <- renderLeaflet({

        filtered <- geocode %>%
            filter(District == values$clicked)

        leaflet() %>%
            addTiles() %>%
            addMarkers(lng = filtered$Longitude, lat = filtered$Latitude, popup = filtered$`District Name`)

    })

})
