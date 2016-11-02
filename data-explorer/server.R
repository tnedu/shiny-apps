## Data Explorer
# server.R

shinyServer(function(input, output, session) {
    
    # Reactive slider
    output$slider <- renderUI({

        ranges <- filter(ranges, Characteristic == input$char)

        sliderInput("range", label = "Adjust Range:", min = ranges$Min, max = ranges$Max,
            value = c(ranges$Min, ranges$Max), ticks = FALSE, width = 500)

    })

    highlight <- reactive({

        # Adjust opacity of highlighted district
        if (input$district != "State of Tennessee") {
            ach_profile[ach_profile$District == input$district, ]$opacity <- 1
            ach_profile[ach_profile$District != input$district & ach_profile$District != "State of Tennessee", ]$opacity <- 0.2
        }

        # Make points with missing outcome data invisible
        ach_profile[is.na(ach_profile[names(ach_profile) == input$outcome]), ]$opacity <- 0
    
        return(ach_profile)

    })

    # Create tooltip with district name, selected x and y variables
    tooltip_scatter <- function(x) {
        row <- ach_profile[ach_profile$District == x$District, ]

        paste0("<b>", row$District, "</b><br>",
            names(district_char)[district_char == input$char], ": ",  row[names(row) == input$char], "<br>",
            names(district_out)[district_out == input$outcome], ": ", row[names(row) == input$outcome])
    }

    # Update highlighted district on point click
    click_district <- function(data, ...) {
        updateSelectInput(session, "district", selected = data$District)
    }

    # Main plot - Scatterplot of district characteristic X outcome
    plot <- reactive({

        # Axis Labels
        xvar_name <- names(district_char)[district_char == input$char]
        yvar_name <- names(district_out)[district_out == input$outcome]

        # Convert input (string) to variable name
        xvar <- prop("x", as.symbol(input$char))
        yvar <- prop("y", as.symbol(input$outcome))
        fillvar <- prop("fill", as.symbol(input$color))

        # Scale vertical axis to [0, 100] if outcome is a % P/A, otherwise, scale to min/max of variable
        if (grepl("Percent Proficient or Advanced", yvar_name)) {
            y_scale <- c(0, 100)
        } else {
            y_scale <- c(min(highlight()[names(highlight()) == input$outcome]),
                ceiling(max(highlight()[names(highlight()) == input$outcome])))
        }

        scatterplot <- highlight() %>%
            ggvis(xvar, yvar, key := ~District) %>%
            layer_points(fill = fillvar, size := 125, size.hover := 300, opacity = ~opacity, opacity.hover := 0.8) %>%
            add_axis("x", title = xvar_name, grid = FALSE) %>%
            add_axis("y", title = yvar_name, grid = FALSE) %>%
            scale_numeric("x", domain = input$range, clamp = TRUE) %>%
            scale_numeric("y", domain = y_scale, expand = 0) %>%
            add_tooltip(tooltip_scatter, on = "hover") %>%
            scale_numeric("opacity", range = c(min(highlight()$opacity), 1)) %>%
            set_options(width = 'auto', height = 650) %>%
            handle_click(click_district)

        if (input$color == "Region") {
            scatterplot %>%
                scale_nominal("fill", range = c('#000000', '#e41a1c', '#377eb8', '#4daf4a', '#984ea3', '#ff7f00', '#ffff33', '#a65628', '#f781bf'))
        } else if (input$color == "Accountability Status") {
            scatterplot %>%
                scale_nominal("fill", domain = c("Exemplary", "Intermediate", "In Need of Subgroup Improvement", "In Need of Improvement"),
                    range = c('#377eb8', '#4daf4a', '#ff7f00', '#e41a1c', '#000000'))
        }
        
    })

    plot %>% bind_shiny("plot")

    # Create tooltip for column chart with subject, demographic percentages
    tooltip_bar <- function(x) {
        long <- ach_profile %>%
            filter(District == input$district) %>%
            select(District, `Black/Hispanic/Native American`, `Economically Disadvantaged`, `English Learners`, `Students with Disabilities`) %>%
            gather(Demographic, Percentage, 2:5) %>%
            filter(Demographic == x$Demographic)

        paste0("<b>", input$district, "</b><br>",
            "Percent ", long$Demographic, ": ", long$Percentage)
    }
    
    # Secondary Plot 1 - Horizontal bar chart with demographics 
    plot2 <- reactive({

        highlight() %>%
            filter(District == input$district) %>%
            select(District, `Black/Hispanic/Native American`, `Economically Disadvantaged`, `English Learners`, `Students with Disabilities`) %>%
            gather(Demographic, Percentage, 2:5) %>%
            ggvis(~Percentage, ~Demographic) %>%
            layer_rects(x2 = 0, height = band(), fill := "blue", fillOpacity := 0.3, fillOpacity.hover := 0.8) %>%
            add_axis("x", grid = FALSE) %>%
            add_axis("y", title = "", grid = FALSE) %>%
            add_tooltip(tooltip_bar, on = "hover") %>%
            scale_numeric("x", domain = c(0, 100), expand = 0) %>%
            set_options(width = 'auto', height = 300)

    })

    plot2 %>% bind_shiny("plot2")

    output$text1 <- renderText(paste(input$district, "Demographics", sep = " "))

    # Create tooltip for column chart with subject, proficiency percentages
    tooltip_column <- function(x) {
        long <- ach_profile %>%
            filter(District == input$district) %>%
            select(District, `Algebra I`:Science) %>%
            gather(subject, Pct_Prof_Adv, 2:11) %>%
            filter(subject == x$subject)

        paste0("<b>", long$subject, "</b><br>",
            "Percent Proficient/Advanced: ", long$Pct_Prof_Adv)
    }

    # Secondary plot 2 - Bar chart of proficiency for selected district
    plot3 <- reactive({

        highlight() %>%
            filter(District == input$district) %>%
            select(District, `Algebra I`:Science) %>%
            gather(subject, Pct_Prof_Adv, 2:11) %>%
            ggvis(~subject, ~Pct_Prof_Adv, key := ~subject) %>%
            layer_bars(fill := "blue", fillOpacity := 0.3, fillOpacity.hover := 0.8) %>%
            add_axis("x", title = "Subject", grid = FALSE) %>%
            add_axis("y", title = "Percent Proficient or Advanced", grid = FALSE) %>%
            add_tooltip(tooltip_column, on = "hover") %>%
            scale_ordinal("x", domain = c("Math", "ELA", "Science", "Algebra I", "Algebra II", "English I", "English II", "English III", "Biology I", "Chemistry")) %>%
            scale_numeric("y", domain = c(0, 100), expand = 0) %>%
            set_options(width = 'auto', height = 300)

    })

    plot3 %>% bind_shiny("plot3")

    output$text2 <- renderText(paste(input$district, "Proficiency in All Subjects"))

    # Reactive user information based on input characteristic and outcome
    output$info1 <- renderText({paste0("The horizontal placement of a point corresponds to a district's ",
        names(district_char)[district_char == input$char], ".")})
    output$info2<- renderText({paste0("The vertical placement of a point corresponds to a district's ",
        names(district_out)[district_out == input$outcome], ".")})

    }
)