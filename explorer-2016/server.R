shinyServer(function(input, output, session) {

    # Filter data based on selected year and highlight selected district
    filtered <- reactive({

        temp <- ach_profile %>%
            filter(Year == as.numeric(input$year)) %>%
            mutate(Selected = 1)

        if (input$highlight != "") {
            mutate(temp, Selected = ifelse(District == input$highlight, 1, 0.3))
        } else {
            return(temp)
        }

    })

    output$scatter <- renderRbokeh({

        if (input$color == "Accountability Status 2015") {
            color_palette <- c("#1f77b4", "#d62728", "#ff7f0e", "#2ca02c", "#7f7f7f")
        } else if (input$color == "Region") {
            color_palette <- c("#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "#9476bd", "#8c564b", "#e377c2", "#7f7f7f", "#bcbd22")
        } else if (grepl("TVAAS", input$color)) {
            color_palette <- c("#d62728", "#ff9896", "#98df8a", "#aec7e8", "#1f77b4", "#7f7f7f")
        } else {
            color_palette <- c("#1f77b4")
        }

        if (input$color != "") {
            tooltip_content <- c("District", input$char, input$outcome, input$color)
        } else {
            tooltip_content <- c("District", input$char, input$outcome)
        }

        p <- figure(xlab = names(district_char[district_char == input$char]),
                ylab = names(district_out[district_out == input$outcome]),
                toolbar_location = "above", legend_location = NULL) %>%
            ly_points(x = input$char, y = input$outcome, alpha = Selected, color = input$color,
                data = filtered(), hover = tooltip_content, lname = "points") %>%
            set_palette(discrete_color = pal_color(color_palette))
            # tool_tap(shiny_callback("tap_info"), "points")

        if (input$char == "Enrollment") {
            x_axis(p, log = TRUE)
        } else {
            return(p)
        }

    })

    # Take only one value if multiple points are clicked
    # values <- reactiveValues(clicked = "")

    # observe({
    #     values$clicked <- filtered()[input$tap_info + 1, ]$District[1]
    # })

    output$map <- renderLeaflet({

        leaflet() %>%
            addTiles() %>%
            addMarkers(lng = geocode[geocode$District == input$highlight, ]$Longitude,
                       lat = geocode[geocode$District == input$highlight, ]$Latitude,
                       popup = paste(sep = "<br/>",
                           paste0("<b>", geocode[geocode$District == input$highlight, ]$`District Name`, "</b>"),
                           geocode[geocode$District == input$highlight, ]$City))

    })

    output$district_name <- renderText(paste("District Name:",
        geocode[geocode$District == input$highlight, ]$`District Name`))

    output$grades_served <- renderText(paste("Grades Served:",
        filtered()[filtered()$District == input$highlight, ]$`Grades Served`))

    output$number_schools <- renderText(paste("Number of Schools:",
        filtered()[filtered()$District == input$highlight, ]$`Number of Schools`))

    output$pct_bhn <- renderText(paste("Percent Black/Hispanic/Native American Students:",
        filtered()[filtered()$District == input$highlight, ]$BHN))

    output$pct_ed <- renderText(paste("Percent Economically Disadvantaged Students:",
        filtered()[filtered()$District == input$highlight, ]$ED))

    output$pct_swd <- renderText(paste("Percent Students with Disabilities:",
        filtered()[filtered()$District == input$highlight, ]$SWD))

    output$pct_el <- renderText(paste("Percent English Learners:",
        filtered()[filtered()$District == input$highlight, ]$EL))

    output$prof <- renderRbokeh({

        temp <- filtered() %>%
            filter(District %in% c(input$highlight, "State of Tennessee")) %>%
            select(District, ELA:`US History`) %>%
            gather(Subject, Value, -District) %>%
            group_by(Subject) %>%
            mutate(Count = sum(!is.na(Value))) %>%
            filter(Count == 2)

        # Don't render plot if district has no data
        if (nrow(temp) == 0) return()

        figure(xlab = "Subject", ylab = "Percent On Track/Mastered", tools = "save") %>%
            ly_bar(x = Subject, y = Value, data = temp, hover = TRUE,
                color = District, position = "dodge")

    })

})
