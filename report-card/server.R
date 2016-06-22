## Report Card
# server.R

shinyServer(function(input, output) {

    output$header_dist <- renderText({paste("District Accountability for", input$district, sep = " ")})
    
    # District determination valueBoxes
    district_determ <- reactive({
        filter(determinations, system_name == input$district)
    })
    
    output$gateBox <- renderValueBox({
        valueBox(district_determ()$minimum_performance_goal, "Minimum Performance Goal", icon = icon("check"),
                 color = color_list[names(color_list) == district_determ()$minimum_performance_goal])
    })
    
    output$achBox <- renderValueBox({
        valueBox(district_determ()$achievement_determination, "Achievement", icon = icon("blackboard", lib = "glyphicon"),
                 color = color_list[names(color_list) == district_determ()$achievement_determination])
    })
    
    output$gapBox <- renderValueBox({
        valueBox(district_determ()$gap_determination, "Gap Closure", icon = icon("arrows-v"),
                 color = color_list[names(color_list) == district_determ()$gap_determination])
    })
    
    output$finalBox <- renderValueBox({
        valueBox(district_determ()$final_determination, "Final Determination", icon = icon("line-chart"),
                 color = color_list[names(color_list) == district_determ()$final_determination])
    })
    
    # District accountability participation table
    output$table_participation <- renderFormattable({
        filter(participation, system_name == input$district) %>%
            select(-c(system, system_name, participation_test_eligible, grade)) %>%
            tidyr::spread(subgroup, participation_test) %>%
            rename("Content Area" = subject, "BHN" = `Black/Hispanic/Native American`, 
                   "ED" = `Economically Disadvantaged`, "SWD" = `Students with Disabilities`, 
                   "EL" = `English Language Learners`, "Super" = `Super Subgroup`) %>%
            formattable(list(
                `All Students` = formatter("span", style = x ~ style(color = ifelse(x == 1, "green", "red")), 
                                           x ~ icontext(ifelse(x == 1, "ok", "remove"), ifelse(x == 1, "Met", "Missed"))),
                BHN = formatter("span", style = x ~ style(color = ifelse(x == 1, "green", "red")), 
                                x ~ icontext(ifelse(x == 1, "ok", "remove"), ifelse(x == 1, "Met", "Missed"))),
                ED = formatter("span", style = x ~ style(color = ifelse(x == 1, "green", "red")), 
                               x ~ icontext(ifelse(x == 1, "ok", "remove"), ifelse(x == 1, "Met", "Missed"))),
                SWD = formatter("span", style = x ~ style(color = ifelse(x == 1, "green", "red")), 
                                x ~ icontext(ifelse(x == 1, "ok", "remove"), ifelse(x == 1, "Met", "Missed"))),
                EL = formatter("span", style = x ~ style(color = ifelse(x == 1, "green", "red")), 
                               x ~ icontext(ifelse(x == 1, "ok", "remove"), ifelse(x == 1, "Met", "Missed"))),
                Super = formatter("span", style = x ~ style(color = ifelse(x == 1, "green", "red")), 
                                  x ~ icontext(ifelse(x == 1, "ok", "remove"), ifelse(x == 1, "Met", "Missed")))
            ))
    })
    
    # District accountability achievement heatmap
    output$ach_heatmap <- renderFlexTable({

        ach_data <- achievement %>%
            arrange(system, grade, desc(subject)) %>%
            filter(system_name == input$district) %>%
            select(one_of(c("subject", "achievement_goal", "tvaas_goal", "best_score"))) %>%
            rename("Content Area" = subject, "Achievement Goal" = achievement_goal, "TVAAS Goal" = tvaas_goal, "Best Score" = best_score)

        ach_table <- FlexTable(data = ach_data, header.par.props = parProperties(text.align = "center"), body.par.props = parProperties(text.align = "center"))
        ach_table <- setFlexTableWidths(ach_table, widths = c(4, 4, 4, 4))

        myCellProps <- cellProperties()

        ach_table[ach_data$`Achievement Goal` == 0, 2] <- chprop(myCellProps, background.color = "red")
        ach_table[ach_data$`Achievement Goal` == 1, 2] <- chprop(myCellProps, background.color = "orange")
        ach_table[ach_data$`Achievement Goal` == 2, 2] <- chprop(myCellProps, background.color = "yellow")
        ach_table[ach_data$`Achievement Goal` == 3, 2] <- chprop(myCellProps, background.color = "green")
        ach_table[ach_data$`Achievement Goal` == 4, 2] <- chprop(myCellProps, background.color = "blue")

        ach_table[ach_data$`TVAAS Goal` == 0, 3] <- chprop(myCellProps, background.color = "red")
        ach_table[ach_data$`TVAAS Goal` == 1, 3] <- chprop(myCellProps, background.color = "orange")
        ach_table[ach_data$`TVAAS Goal` == 2, 3] <- chprop(myCellProps, background.color = "yellow")
        ach_table[ach_data$`TVAAS Goal` == 3, 3] <- chprop(myCellProps, background.color = "green")
        ach_table[ach_data$`TVAAS Goal` == 4, 3] <- chprop(myCellProps, background.color = "blue")

        ach_table[ach_data$`Best Score` == 0, 4] <- chprop(myCellProps, background.color = "red")
        ach_table[ach_data$`Best Score` == 1, 4] <- chprop(myCellProps, background.color = "orange")
        ach_table[ach_data$`Best Score` == 2, 4] <- chprop(myCellProps, background.color = "yellow")
        ach_table[ach_data$`Best Score` == 3, 4] <- chprop(myCellProps, background.color = "green")
        ach_table[ach_data$`Best Score` == 4, 4] <- chprop(myCellProps, background.color = "blue")
        
        ach_table <- addFooterRow(ach_table, value = c("Achievement Score", paste(sprintf("%.2f", mean(ach_data$`Best Score`, na.rm = TRUE)))),
                                colspan = c(1, 3))

        return(ach_table)

    })

    output$ach_legend <- renderFlexTable({

        ach_legend <- data.frame(0:4, c("Rank decreased by more than 10 points compared to the previous year",
                                        "Rank decreased by more than 2 points and fewer than 10 points compared to the previous year",
                                        "Rank stayed the same or decreased by no more than 2 points compared to the previous year",
                                        "Rank increased by fewer than 10 points compared to the previous year OR district has percentile rank of 95% or higher in both the current and previous year",
                                        "Rank increased by 10 or more points compared to the previous year"),
                                 c("Level 1", "Level 2", "Level 3", "Level 4", "Level 5"),
                                 c("Regressing or no improvement", "Improvement, but not meeting growth expectation or performance goal",
                                   "Meeting growth expectation or performance goal", "Exceeding growth expectation or performance goal",
                                   "Greatly exceeding growth expectation or performance goal"))

        names(ach_legend) <- c("Points", "Relative Achievement Goal", "TVAAS Goal", "Definition")

        ach_legend_table <- FlexTable(ach_legend, header.par.props = parProperties(text.align = "center"), body.par.props = parProperties(text.align = "center"))
        ach_legend_table <- setFlexTableWidths(ach_legend_table, widths = c(4, 4, 4, 4))

        return(ach_legend_table)

    })

    output$ach_map <- renderFlexTable({

        ach_map <- data.frame(c("Achievement Score", "Definition"), 
                              c("Below 2.0", "District is improving on average but missing growth expectation"),
                              c("2.0 to 2.99", "District is meeting growth expectation on average."),
                              c("3.0 and above", "District is exceeding growth expectation on average."))

        names(ach_map) <- c("Determination", "Progressing", "Achieving", "Exemplary")

        ach_map_table <- FlexTable(ach_map, header.par.props = parProperties(text.align = "center"), body.par.props = parProperties(text.align = "center"))
        ach_map_table <- setFlexTableWidths(ach_map_table, widths = c(4, 4, 4, 4))
        ach_map_table[, 1] <- textProperties(font.weight = "bold")

        return(ach_map_table)

    })

    # District accountability gap heatmap
    output$final_gap <- renderFlexTable({

        final_gap <- gap_closure %>%
            filter(system_name == input$district) %>%
            tidyr::unite(subject_grade, subject, grade) %>%
            select(one_of(c("subject_grade", "subgroup", "best_score"))) %>%
            tidyr::spread("subgroup", "best_score") %>%
            tidyr::separate(subject_grade, c("subject", "grade"), sep = "_") %>%
            arrange(grade, desc(subject)) %>%
            select(-grade) %>%
            rename("Content Area" = subject)

        final_gap_table <- FlexTable(final_gap, header.par.props = parProperties(text.align = "center"), body.par.props = parProperties(text.align = "center"))
        final_gap_table <- setFlexTableWidths(final_gap_table, widths = c(3, 3, 3, 3, 3))
        
        myCellProps <- cellProperties()
        
        final_gap_table[final_gap$`Black/Hispanic/Native American` == 0, 2] <- chprop(myCellProps, background.color = "red")
        final_gap_table[final_gap$`Black/Hispanic/Native American` == 1, 2] <- chprop(myCellProps, background.color = "orange")
        final_gap_table[final_gap$`Black/Hispanic/Native American` == 2, 2] <- chprop(myCellProps, background.color = "yellow")
        final_gap_table[final_gap$`Black/Hispanic/Native American` == 3, 2] <- chprop(myCellProps, background.color = "green")
        final_gap_table[final_gap$`Black/Hispanic/Native American` == 4, 2] <- chprop(myCellProps, background.color = "blue")

        final_gap_table[final_gap$`Economically Disadvantaged` == 0, 3] <- chprop(myCellProps, background.color = "red")
        final_gap_table[final_gap$`Economically Disadvantaged` == 1, 3] <- chprop(myCellProps, background.color = "orange")
        final_gap_table[final_gap$`Economically Disadvantaged` == 2, 3] <- chprop(myCellProps, background.color = "yellow")
        final_gap_table[final_gap$`Economically Disadvantaged` == 3, 3] <- chprop(myCellProps, background.color = "green")
        final_gap_table[final_gap$`Economically Disadvantaged` == 4, 3] <- chprop(myCellProps, background.color = "blue")

        final_gap_table[final_gap$`English Language Learners` == 0, 4] <- chprop(myCellProps, background.color = "red")
        final_gap_table[final_gap$`English Language Learners` == 1, 4] <- chprop(myCellProps, background.color = "orange")
        final_gap_table[final_gap$`English Language Learners` == 2, 4] <- chprop(myCellProps, background.color = "yellow")
        final_gap_table[final_gap$`English Language Learners` == 3, 4] <- chprop(myCellProps, background.color = "green")
        final_gap_table[final_gap$`English Language Learners` == 4, 4] <- chprop(myCellProps, background.color = "blue")

        final_gap_table[final_gap$`Students with Disabilities` == 0, 5] <- chprop(myCellProps, background.color = "red")
        final_gap_table[final_gap$`Students with Disabilities` == 1, 5] <- chprop(myCellProps, background.color = "orange")
        final_gap_table[final_gap$`Students with Disabilities` == 2, 5] <- chprop(myCellProps, background.color = "yellow")
        final_gap_table[final_gap$`Students with Disabilities` == 3, 5] <- chprop(myCellProps, background.color = "green")
        final_gap_table[final_gap$`Students with Disabilities` == 4, 5] <- chprop(myCellProps, background.color = "blue")

        final_gap_table <- addFooterRow(final_gap_table, 
                                        value = c("Subgroup Average", 
                                                  paste(sprintf("%.2f", mean(final_gap$`Black/Hispanic/Native American`, na.rm = TRUE))),
                                                  paste(sprintf("%.2f", mean(final_gap$`Economically Disadvantaged`, na.rm = TRUE))),
                                                  paste(sprintf("%.2f", mean(final_gap$`English Language Learners`, na.rm = TRUE))),
                                                  paste(sprintf("%.2f", mean(final_gap$`Students with Disabilities`, na.rm = TRUE)))), 
                                        colspan = c(1, 1, 1, 1, 1))
        final_gap_table <- addFooterRow(final_gap_table, 
                                        value = c("Overall Gap Closure Average", 
                                                  paste(sprintf("%.2f",
                                                                mean(c(mean(final_gap$`Black/Hispanic/Native American`, na.rm = TRUE), mean(final_gap$`Economically Disadvantaged`, na.rm = TRUE), 
                                                                    mean(final_gap$`English Language Learners`, na.rm = TRUE),  mean(final_gap$`Students with Disabilities`, na.rm = TRUE)), na.rm = TRUE)))),
                                                   colspan = c(1, 4))
        
        return(final_gap_table)

    })
    
})