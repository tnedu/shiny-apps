## Report Card
# server.R

shinyServer(function(input, output) {

    ## District Accountability Tab
    # District determinations
    output$header_dist_acct <- renderText({paste("District Accountability for", input$district, sep = " ")})

    district_determ <- reactive({
        filter(determinations, system_name == input$district)
    })

    output$gateBox <- renderValueBox({
        valueBox(district_determ()$minimum_performance_goal, "Minimum Performance Goal", icon = icon("check"),
                 color = color_list[names(color_list) == district_determ()$minimum_performance_goal])
    })

    output$achBox <- renderValueBox({
        valueBox(district_determ()$achievement_determination, "Achievement Determination", icon = icon("blackboard", lib = "glyphicon"),
                 color = color_list[names(color_list) == district_determ()$achievement_determination])
    })

    output$gapBox <- renderValueBox({
        valueBox(district_determ()$gap_determination, "Gap Closure Determination", icon = icon("arrows-v"),
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
            spread(subgroup, participation_test) %>%
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

    # District accountability minimum performance goal
    output$gate_heatmap <- renderFlexTable({

        gate_data <- performance_gate %>%
            filter(system_name == input$district) %>%
            select(one_of(c("subject", "achievement_key", "tvaas_key", "gap_BB_reduction_key", "gap_tvaas_key"))) %>%
            rename("Content Area" = subject, "Achievement Goal" = achievement_key, "TVAAS Goal" = tvaas_key,
                   "Below Basic Reduction" = gap_BB_reduction_key, "Super Subgroup TVAAS" = gap_tvaas_key)

        gate_table <- FlexTable(data = gate_data, header.par.props = parProperties(text.align = "center"), body.par.props = parProperties(text.align = "center"))
        setFlexTableWidths(gate_table, widths = c(4, 4, 4, 4, 4))

        myCellProps <- cellProperties()

        gate_table[gate_data$`Achievement Goal` == "Yes", 2] <- chprop(myCellProps, background.color = "blue")
        gate_table[gate_data$`Achievement Goal` == "No", 2] <- chprop(myCellProps, background.color = "red")

        gate_table[gate_data$`TVAAS Goal` == "Yes", 3] <- chprop(myCellProps, background.color = "blue")
        gate_table[gate_data$`TVAAS Goal` == "No", 3] <- chprop(myCellProps, background.color = "red")

        gate_table[gate_data$`Below Basic Reduction` == "Yes", 4] <- chprop(myCellProps, background.color = "blue")
        gate_table[gate_data$`Below Basic Reduction` == "No", 4] <- chprop(myCellProps, background.color = "red")

        gate_table[gate_data$`Super Subgroup TVAAS` == "Yes", 5] <- chprop(myCellProps, background.color = "blue")
        gate_table[gate_data$`Super Subgroup TVAAS` == "No", 5] <- chprop(myCellProps, background.color = "red")

        addFooterRow(gate_table, value = c("Measures Met",
                                            paste(nrow(filter(performance_gate, system_name == input$district & achievement_key == "Yes"))),
                                            paste(nrow(filter(performance_gate, system_name == input$district & tvaas_key == "Yes"))),
                                            paste(nrow(filter(performance_gate, system_name == input$district & (gap_BB_reduction_key == "Yes" | gap_tvaas_key == "Yes"))))),
                                            colspan = c(1, 1, 1, 2))
        addFooterRow(gate_table, value = c("Eligible Measures",
                                            paste(nrow(filter(performance_gate, system_name == input$district & achievement_key != "."))),
                                            paste(nrow(filter(performance_gate, system_name == input$district & tvaas_key != "."))),
                                            paste(nrow(filter(performance_gate, system_name == input$district & (gap_BB_reduction_key != "." | gap_tvaas_key != "."))))),
                                            colspan = c(1, 1, 1, 2))
        addFooterRow(gate_table, value = c("Percent of Measures Met",
                                            paste(sprintf("%.1f", 100 * nrow(filter(performance_gate, system_name == input$district & achievement_key == "Yes"))/
                                               nrow(filter(performance_gate, system_name == input$district & achievement_key != "."))), "%"),
                                            paste(sprintf("%.1f", 100 * nrow(filter(performance_gate, system_name == input$district & tvaas_key == "Yes"))/
                                               nrow(filter(performance_gate, system_name == input$district & tvaas_key != "."))), "%"),
                                            paste(sprintf("%.1f", 100 * nrow(filter(performance_gate, system_name == input$district & (gap_BB_reduction_key == "Yes" | gap_tvaas_key == "Yes")))/
                                               nrow(filter(performance_gate, system_name == input$district & (gap_BB_reduction_key != "." | gap_tvaas_key != ".")))), "%")),
                                            colspan = c(1, 1, 1 ,2))
        addFooterRow(gate_table, value = c("Minimum Performance Goals",
                                            "Did the district maintain or improve its relative percentile rank in terms of % P/A in at least 25% of eligible content areas?",
                                            "Did the district demonstrate growth through TVAAS in at least 25% of eligible content areas?",
                                            "Did the district either
                                            1) decrease its relative percentile rank for its Super Subgroup in terms of % BB in at least 25% of eligible content areas OR
                                            2) demonstrate growth through a Super Subgroup TVAAS level 3 or higher?"),
                                            colspan = c(1, 1, 1, 2))

        return(gate_table)

    })

    # District accountability achievement heatmap
    output$ach_heatmap <- renderFlexTable({

        ach_data <- achievement %>%
            filter(system_name == input$district) %>%
            arrange(grade, desc(subject)) %>%
            select(one_of(c("subject", "achievement_goal", "tvaas_goal", "best_score"))) %>%
            rename("Content Area" = subject, "Achievement Goal" = achievement_goal, "TVAAS Goal" = tvaas_goal, "Best Score" = best_score)

        ach_table <- FlexTable(data = ach_data, header.par.props = parProperties(text.align = "center"), body.par.props = parProperties(text.align = "center"))
        setFlexTableWidths(ach_table, widths = c(4, 4, 4, 4))

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

        addFooterRow(ach_table, value = c("Achievement Score", paste(sprintf("%.2f", mean(ach_data$`Best Score`, na.rm = TRUE)))),
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
        setFlexTableWidths(ach_legend_table, widths = c(4, 4, 4, 4))

        return(ach_legend_table)

    })

    output$ach_map <- renderFlexTable({

        ach_map <- data.frame(c("Achievement Score", "Definition"), 
                              c("Below 2.0", "District is improving on average but missing growth expectation"),
                              c("2.0 to 2.99", "District is meeting growth expectation on average."),
                              c("3.0 and above", "District is exceeding growth expectation on average."))

        names(ach_map) <- c("Determination", "Progressing", "Achieving", "Exemplary")

        ach_map_table <- FlexTable(ach_map, header.par.props = parProperties(text.align = "center"), body.par.props = parProperties(text.align = "center"))
        setFlexTableWidths(ach_map_table, widths = c(4, 4, 4, 4))
        ach_map_table[, 1] <- textProperties(font.weight = "bold")

        return(ach_map_table)

    })

    # District accountability gap heatmaps
    output$final_gap <- renderFlexTable({

        final_gap <- gap_closure %>%
            filter(system_name == input$district) %>%
            unite(subject_grade, subject, grade) %>%
            select(one_of(c("subject_grade", "subgroup", "best_score"))) %>%
            spread("subgroup", "best_score") %>%
            separate(subject_grade, c("subject", "grade"), sep = "_") %>%
            arrange(grade, desc(subject)) %>%
            select(-grade) %>%
            rename("Content Area" = subject)

        final_gap_table <- FlexTable(final_gap, header.par.props = parProperties(text.align = "center"), body.par.props = parProperties(text.align = "center"))
        setFlexTableWidths(final_gap_table, widths = c(3, 3, 3, 3, 3))

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

        addFooterRow(final_gap_table, 
                     value = c("Subgroup Average", 
                               paste(sprintf("%.2f", mean(final_gap$`Black/Hispanic/Native American`, na.rm = TRUE))),
                               paste(sprintf("%.2f", mean(final_gap$`Economically Disadvantaged`, na.rm = TRUE))),
                               paste(sprintf("%.2f", mean(final_gap$`English Language Learners`, na.rm = TRUE))),
                               paste(sprintf("%.2f", mean(final_gap$`Students with Disabilities`, na.rm = TRUE)))), 
                     colspan = c(1, 1, 1, 1, 1))
        addFooterRow(final_gap_table, 
                     value = c("Overall Gap Closure Score", 
                              paste(sprintf("%.2f", mean(c(mean(final_gap$`Black/Hispanic/Native American`, na.rm = TRUE),
                                                           mean(final_gap$`Economically Disadvantaged`, na.rm = TRUE), 
                                                           mean(final_gap$`English Language Learners`, na.rm = TRUE), 
                                                           mean(final_gap$`Students with Disabilities`, na.rm = TRUE)), na.rm = TRUE)))), colspan = c(1, 4))

        return(final_gap_table)

    })

    output$bhn_gap <- renderFlexTable({

        bhn_gap <- gap_closure %>%
            filter(system_name == input$district & subgroup == "Black/Hispanic/Native American") %>%
            arrange(grade, desc(subject)) %>%
            select(one_of(c("subject", "subgroup_achievement_goal", "subgroup_tvaas_goal", "best_score"))) %>%
            rename("Content Area" = subject, "Subgroup Achievement Goal" = subgroup_achievement_goal, 
                   "Subgroup TVAAS Goal" = subgroup_tvaas_goal, "Best Score" = best_score)

        bhn_table <- FlexTable(data = bhn_gap, header.par.props = parProperties(text.align = "center"), body.par.props = parProperties(text.align = "center"))
        setFlexTableWidths(bhn_table, widths = c(4, 4, 4, 4))

        myCellProps <- cellProperties()

        bhn_table[bhn_gap$`Subgroup Achievement Goal` == 0, 2] <- chprop(myCellProps, background.color = "red")
        bhn_table[bhn_gap$`Subgroup Achievement Goal` == 1, 2] <- chprop(myCellProps, background.color = "orange")
        bhn_table[bhn_gap$`Subgroup Achievement Goal` == 2, 2] <- chprop(myCellProps, background.color = "yellow")
        bhn_table[bhn_gap$`Subgroup Achievement Goal` == 3, 2] <- chprop(myCellProps, background.color = "green")
        bhn_table[bhn_gap$`Subgroup Achievement Goal` == 4, 2] <- chprop(myCellProps, background.color = "blue")

        bhn_table[bhn_gap$`Subgroup TVAAS Goal` == 0, 3] <- chprop(myCellProps, background.color = "red")
        bhn_table[bhn_gap$`Subgroup TVAAS Goal` == 1, 3] <- chprop(myCellProps, background.color = "orange")
        bhn_table[bhn_gap$`Subgroup TVAAS Goal` == 2, 3] <- chprop(myCellProps, background.color = "yellow")
        bhn_table[bhn_gap$`Subgroup TVAAS Goal` == 3, 3] <- chprop(myCellProps, background.color = "green")
        bhn_table[bhn_gap$`Subgroup TVAAS Goal` == 4, 3] <- chprop(myCellProps, background.color = "blue")

        bhn_table[bhn_gap$`Best Score` == 0, 4] <- chprop(myCellProps, background.color = "red")
        bhn_table[bhn_gap$`Best Score` == 1, 4] <- chprop(myCellProps, background.color = "orange")
        bhn_table[bhn_gap$`Best Score` == 2, 4] <- chprop(myCellProps, background.color = "yellow")
        bhn_table[bhn_gap$`Best Score` == 3, 4] <- chprop(myCellProps, background.color = "green")
        bhn_table[bhn_gap$`Best Score` == 4, 4] <- chprop(myCellProps, background.color = "blue")

        addFooterRow(bhn_table, value = c("BHN Achievement Score", paste(sprintf("%.2f", mean(bhn_gap$`Best Score`, na.rm = TRUE)))),
                     colspan = c(1, 3))

        return(bhn_table)

    })

    output$ed_gap <- renderFlexTable({

        ed_gap <- gap_closure %>%
            filter(system_name == input$district & subgroup == "Economically Disadvantaged") %>%
            arrange(grade, desc(subject)) %>%
            select(one_of(c("subject", "subgroup_achievement_goal", "subgroup_tvaas_goal", "best_score"))) %>%
            rename("Content Area" = subject, "Subgroup Achievement Goal" = subgroup_achievement_goal, 
                   "Subgroup TVAAS Goal" = subgroup_tvaas_goal, "Best Score" = best_score)

        ed_table <- FlexTable(data = ed_gap, header.par.props = parProperties(text.align = "center"), body.par.props = parProperties(text.align = "center"))
        setFlexTableWidths(ed_table, widths = c(4, 4, 4, 4))

        myCellProps <- cellProperties()

        ed_table[ed_gap$`Subgroup Achievement Goal` == 0, 2] <- chprop(myCellProps, background.color = "red")
        ed_table[ed_gap$`Subgroup Achievement Goal` == 1, 2] <- chprop(myCellProps, background.color = "orange")
        ed_table[ed_gap$`Subgroup Achievement Goal` == 2, 2] <- chprop(myCellProps, background.color = "yellow")
        ed_table[ed_gap$`Subgroup Achievement Goal` == 3, 2] <- chprop(myCellProps, background.color = "green")
        ed_table[ed_gap$`Subgroup Achievement Goal` == 4, 2] <- chprop(myCellProps, background.color = "blue")

        ed_table[ed_gap$`Subgroup TVAAS Goal` == 0, 3] <- chprop(myCellProps, background.color = "red")
        ed_table[ed_gap$`Subgroup TVAAS Goal` == 1, 3] <- chprop(myCellProps, background.color = "orange")
        ed_table[ed_gap$`Subgroup TVAAS Goal` == 2, 3] <- chprop(myCellProps, background.color = "yellow")
        ed_table[ed_gap$`Subgroup TVAAS Goal` == 3, 3] <- chprop(myCellProps, background.color = "green")
        ed_table[ed_gap$`Subgroup TVAAS Goal` == 4, 3] <- chprop(myCellProps, background.color = "blue")

        ed_table[ed_gap$`Best Score` == 0, 4] <- chprop(myCellProps, background.color = "red")
        ed_table[ed_gap$`Best Score` == 1, 4] <- chprop(myCellProps, background.color = "orange")
        ed_table[ed_gap$`Best Score` == 2, 4] <- chprop(myCellProps, background.color = "yellow")
        ed_table[ed_gap$`Best Score` == 3, 4] <- chprop(myCellProps, background.color = "green")
        ed_table[ed_gap$`Best Score` == 4, 4] <- chprop(myCellProps, background.color = "blue")

        addFooterRow(ed_table, value = c("ED Achievement Score", paste(sprintf("%.2f", mean(ed_gap$`Best Score`, na.rm = TRUE)))),
                      colspan = c(1, 3))

        return(ed_table)

    })

    output$swd_gap <- renderFlexTable({

        swd_gap <- gap_closure %>%
            filter(system_name == input$district & subgroup == "Students with Disabilities") %>%
            arrange(grade, desc(subject)) %>%
            select(one_of(c("subject", "subgroup_achievement_goal", "subgroup_tvaas_goal", "best_score"))) %>%
            rename("Content Area" = subject, "Subgroup Achievement Goal" = subgroup_achievement_goal, 
                   "Subgroup TVAAS Goal" = subgroup_tvaas_goal, "Best Score" = best_score)

        swd_table <- FlexTable(data = swd_gap, header.par.props = parProperties(text.align = "center"), body.par.props = parProperties(text.align = "center"))
        setFlexTableWidths(swd_table, widths = c(4, 4, 4, 4))

        myCellProps <- cellProperties()

        swd_table[swd_gap$`Subgroup Achievement Goal` == 0, 2] <- chprop(myCellProps, background.color = "red")
        swd_table[swd_gap$`Subgroup Achievement Goal` == 1, 2] <- chprop(myCellProps, background.color = "orange")
        swd_table[swd_gap$`Subgroup Achievement Goal` == 2, 2] <- chprop(myCellProps, background.color = "yellow")
        swd_table[swd_gap$`Subgroup Achievement Goal` == 3, 2] <- chprop(myCellProps, background.color = "green")
        swd_table[swd_gap$`Subgroup Achievement Goal` == 4, 2] <- chprop(myCellProps, background.color = "blue")

        swd_table[swd_gap$`Subgroup TVAAS Goal` == 0, 3] <- chprop(myCellProps, background.color = "red")
        swd_table[swd_gap$`Subgroup TVAAS Goal` == 1, 3] <- chprop(myCellProps, background.color = "orange")
        swd_table[swd_gap$`Subgroup TVAAS Goal` == 2, 3] <- chprop(myCellProps, background.color = "yellow")
        swd_table[swd_gap$`Subgroup TVAAS Goal` == 3, 3] <- chprop(myCellProps, background.color = "green")
        swd_table[swd_gap$`Subgroup TVAAS Goal` == 4, 3] <- chprop(myCellProps, background.color = "blue")

        swd_table[swd_gap$`Best Score` == 0, 4] <- chprop(myCellProps, background.color = "red")
        swd_table[swd_gap$`Best Score` == 1, 4] <- chprop(myCellProps, background.color = "orange")
        swd_table[swd_gap$`Best Score` == 2, 4] <- chprop(myCellProps, background.color = "yellow")
        swd_table[swd_gap$`Best Score` == 3, 4] <- chprop(myCellProps, background.color = "green")
        swd_table[swd_gap$`Best Score` == 4, 4] <- chprop(myCellProps, background.color = "blue")

        addFooterRow(swd_table, value = c("SWD Achievement Score", paste(sprintf("%.2f", mean(swd_gap$`Best Score`, na.rm = TRUE)))),
                     colspan = c(1, 3))

        return(swd_table)
    })

    output$ell_gap <- renderFlexTable({

        ell_gap <- gap_closure %>%
            filter(system_name == input$district & subgroup == "English Language Learners") %>%
            arrange(grade, desc(subject)) %>%
            select(one_of(c("subject", "subgroup_achievement_goal", "subgroup_tvaas_goal", "best_score"))) %>%
            rename("Content Area" = subject, "Subgroup Achievement Goal" = subgroup_achievement_goal, 
                   "Subgroup TVAAS Goal" = subgroup_tvaas_goal, "Best Score" = best_score)

        ell_table <- FlexTable(data = ell_gap, header.par.props = parProperties(text.align = "center"), body.par.props = parProperties(text.align = "center"))
        setFlexTableWidths(ell_table, widths = c(4, 4, 4, 4))

        myCellProps <- cellProperties()

        ell_table[ell_gap$`Subgroup Achievement Goal` == 0, 2] <- chprop(myCellProps, background.color = "red")
        ell_table[ell_gap$`Subgroup Achievement Goal` == 1, 2] <- chprop(myCellProps, background.color = "orange")
        ell_table[ell_gap$`Subgroup Achievement Goal` == 2, 2] <- chprop(myCellProps, background.color = "yellow")
        ell_table[ell_gap$`Subgroup Achievement Goal` == 3, 2] <- chprop(myCellProps, background.color = "green")
        ell_table[ell_gap$`Subgroup Achievement Goal` == 4, 2] <- chprop(myCellProps, background.color = "blue")

        ell_table[ell_gap$`Subgroup TVAAS Goal` == 0, 3] <- chprop(myCellProps, background.color = "red")
        ell_table[ell_gap$`Subgroup TVAAS Goal` == 1, 3] <- chprop(myCellProps, background.color = "orange")
        ell_table[ell_gap$`Subgroup TVAAS Goal` == 2, 3] <- chprop(myCellProps, background.color = "yellow")
        ell_table[ell_gap$`Subgroup TVAAS Goal` == 3, 3] <- chprop(myCellProps, background.color = "green")
        ell_table[ell_gap$`Subgroup TVAAS Goal` == 4, 3] <- chprop(myCellProps, background.color = "blue")

        ell_table[ell_gap$`Best Score` == 0, 4] <- chprop(myCellProps, background.color = "red")
        ell_table[ell_gap$`Best Score` == 1, 4] <- chprop(myCellProps, background.color = "orange")
        ell_table[ell_gap$`Best Score` == 2, 4] <- chprop(myCellProps, background.color = "yellow")
        ell_table[ell_gap$`Best Score` == 3, 4] <- chprop(myCellProps, background.color = "green")
        ell_table[ell_gap$`Best Score` == 4, 4] <- chprop(myCellProps, background.color = "blue")

        addFooterRow(ell_table, value = c("ELL Achievement Score", paste(sprintf("%.2f", mean(ell_gap$`Best Score`, na.rm = TRUE)))),
                     colspan = c(1, 3))
        
        return(ell_table)
    })

    output$gap_legend <- renderFlexTable({
        
        gap_legend <- data.frame(0:4, c("Rank increased by more than 10 points compraed to the previous year",
                                        "Rank increased by more than 2 points and fewer than 10 points compraed to the previous year",
                                        "Rank stayed the same or increased by no more than 2 points compared to the previous year",
                                        "Rank decreased by fewer than 10 points compared to the previous year OR district has percentile rank of 95% or higher in both the current and previous year",
                                        "Rank decreased by 10 or more points compared to the previous year"),
                                 c("Level 1", "Level 2", "Level 3", "Level 4", "Level 5"),
                                 c("Regressing or no improvement", "Improvement, but not meeting growth expectation or performance goal",
                                   "Meeting growth expectation or performance goal", "Exceeding growth expectation or performance goal",
                                   "Greatly exceeding growth expectation or performance goal"))

        names(gap_legend) <- c("Points", "Subgroup Relative Achievement Goal", "Subgroup TVAAS Goal", "Definition")

        gap_legend_table <- FlexTable(gap_legend, header.par.props = parProperties(text.align = "center"), body.par.props = parProperties(text.align = "center"))
        setFlexTableWidths(gap_legend_table, widths = c(4, 4, 4, 4))

        return(gap_legend_table)

    })

    output$gap_map <- renderFlexTable({

        gap_map <- data.frame(c("Gap Closure Score", "Definition"),
                              c("Below 2.0", "District is improving on average but missing growth expectation"),
                              c("2.0 to 2.99", "District is meeting growth expectation on average."),
                              c("3.0 and above", "District is exceeding growth expectation on average."))

        names(gap_map) <- c("Determination", "Progressing", "Achieving", "Exemplary")

        gap_map_table <- FlexTable(gap_map, header.par.props = parProperties(text.align = "center"), body.par.props = parProperties(text.align = "center"))
        setFlexTableWidths(gap_map_table, widths = c(4, 4, 4, 4))
        gap_map_table[, 1] <- textProperties(font.weight = "bold")

        return(gap_map_table)

    })

    ## District Comparison Tab
    # Identify most similar districts based on vector of selected characteristics
    similarityData <- reactive({

        req(input$district_chars)

        chars <- select(profile_std, one_of(c("system_name", input$district_chars)))
        df2 <- chars[complete.cases(chars), ]

        similarity <- data.frame(system_name = df2[, 1], similarity_score = NA, stringsAsFactors = FALSE)

        # Compute vector of similarity scores against selected district
        for (i in 1:nrow(df2)) {
            similarity[i, 2] <- sqrt(sum((df2[i,2:ncol(df2)] - df2[which(df2$system_name == input$district), 2:ncol(df2)])^2))
        }

        # Select 8 most similar districts
        similarity %>%
            arrange(similarity_score) %>%
            inner_join(df_outcomes, by = "system_name") %>%
            slice(1:9)

    })

    # Create tooltip with district name and proficiency %
    tooltip_comp <- function(x) {
        if (is.null(x)) return(NULL)
        row <- ach_profile[ach_profile$system_name == x$system_name, ]

        paste0("<b>", row$system_name, "</b><br>",
               names(outcome_list)[outcome_list == input$outcome], ": ",
               row[names(row) == input$outcome])
    }

    # Extract district number of clicked point for secondary table
    clicked <- reactiveValues(district = "")
    click_district <- function(data, ...) {
        clicked$district <- as.character(data$system_name)
    }

    # Column chart of proficiency for selected, similar districts
    plot_prof <- reactive({

        # Label for vertical axis
        yvar_name <- names(outcome_list[outcome_list == input$outcome])

        # Convert subject input (string) to variable name
        yvar <- prop("y", as.symbol(input$outcome))

        # Scale vertical axis to [0, 100] if outcome is a % P/A, otherwise, scale to min/max of variable
        if (grepl("Percent Proficient or Advanced", yvar_name)) {
            y_scale <- c(0, 100)
        } else {
            y_scale <- c(floor(min(df_outcomes[names(df_outcomes) == input$outcome])), 
                         ceiling(max(df_outcomes[names(df_outcomes) == input$outcome])))
        }

        similarityData() %>%
            ggvis(~system_name, yvar, key := ~system_name) %>%
            layer_bars(fill := "blue", fillOpacity := 0.3, fillOpacity.hover := 0.8) %>%
            add_axis("x", title = "District", grid = FALSE) %>%
            add_axis("y", title = yvar_name, grid = FALSE) %>%
            add_tooltip(tooltip_comp, on = "hover") %>%
            scale_ordinal("x", domain = similarityData()$system_name) %>%
            scale_numeric("y", domain = y_scale) %>%
            set_options(width = 'auto', height = 600) %>%
            handle_click(click_district)

    })

    plot_prof %>% bind_shiny("plot_prof")

    output$header_comp <- renderText({paste(names(outcome_list[outcome_list == input$outcome]), "for districts most similar to", input$district, sep = " ")})

    # Table with profile data for selected, clicked districts
    output$table <- renderFlexTable({
        
        df_comparison <- df_profile %>%
            select(one_of(c("system_name", "Enrollment", "Pct_Black", "Pct_Hispanic", "Pct_Native_American", "Pct_ED", "Pct_SWD", "Pct_EL", "Per_Pupil_Expenditures"))) %>%
            rename("Per-Pupil Expenditures" = Per_Pupil_Expenditures, "Percent Black" = Pct_Black,
                   "Percent Hispanic" = Pct_Hispanic, "Percent Native American" = Pct_Native_American, 
                   "Percent Economically Disadvantaged" = Pct_ED, "Percent Students with Disabilities" = Pct_SWD,
                   "Percent English Learners" = Pct_EL) %>%
            filter(system_name == input$district | system_name == clicked$district) %>%
            gather("Characteristic", "value", 2:9) %>%
            spread("system_name", "value")
        
        # Create new column with differences between selected, clicked districts
        if (clicked$district != "" & clicked$district != input$district) {
            df_comparison$Difference <- df_comparison[, names(df_comparison) == input$district] - df_comparison[, names(df_comparison) == clicked$district]
        }
        
        order <- c("Enrollment", "Per-Pupil Expenditures", "Percent Economically Disadvantaged", "Percent Students with Disabilities", 
                   "Percent English Learners", "Percent Black", "Percent Hispanic", "Percent Native American")
        df_comparison <- df_comparison[match(order, df_comparison$Characteristic), ]
        rownames(df_comparison) <- NULL
        
        comp_table <- FlexTable(df_comparison, header.par.props = parProperties(text.align = "center"), body.par.props = parProperties(text.align = "center"))
        
        if (ncol(df_comparison) == 4) {
            setFlexTableWidths(comp_table, widths = c(5, 3, 3, 3))
            
            myCellProps <- cellProperties()
            
            comp_table[df_comparison$Characteristic == "Enrollment" & abs(df_comparison$Difference) >= standard_devs$Enrollment, 4] = chprop(myCellProps, background.color = "orange")
            comp_table[df_comparison$Characteristic == "Enrollment" & abs(df_comparison$Difference) >= 0.5 * standard_devs$Enrollment & abs(df_comparison$Difference) < standard_devs$Enrollment, 4] = chprop(myCellProps, background.color = "yellow")
            
            comp_table[df_comparison$Characteristic == "Per-Pupil Expenditures" & abs(df_comparison$Difference) >= standard_devs$Per_Pupil_Expenditures, 4] = chprop(myCellProps, background.color = "orange")
            comp_table[df_comparison$Characteristic == "Per-Pupil Expenditures" & abs(df_comparison$Difference) >= 0.5 * standard_devs$Per_Pupil_Expenditures & abs(df_comparison$Difference) < standard_devs$Per_Pupil_Expenditures, 4] = chprop(myCellProps, background.color = "yellow")
            
            comp_table[df_comparison$Characteristic == "Percent Economically Disadvantaged" & abs(df_comparison$Difference) >= standard_devs$Pct_ED, 4] = chprop(myCellProps, background.color = "orange")
            comp_table[df_comparison$Characteristic == "Percent Economically Disadvantaged" & abs(df_comparison$Difference) >= 0.5 * standard_devs$Pct_ED & abs(df_comparison$Difference) < standard_devs$Pct_ED, 4] = chprop(myCellProps, background.color = "yellow")
            
            comp_table[df_comparison$Characteristic == "Percent Students with Disabilities" & abs(df_comparison$Difference) >= standard_devs$Pct_SWD, 4] = chprop(myCellProps, background.color = "orange")
            comp_table[df_comparison$Characteristic == "Percent Students with Disabilities" & abs(df_comparison$Difference) >= 0.5 * standard_devs$Pct_SWD & abs(df_comparison$Difference) < standard_devs$Pct_SWD, 4] = chprop(myCellProps, background.color = "yellow")
            
            comp_table[df_comparison$Characteristic == "Percent English Learners" & abs(df_comparison$Difference) >= standard_devs$Pct_EL, 4] = chprop(myCellProps, background.color = "orange")
            comp_table[df_comparison$Characteristic == "Percent English Learners" & abs(df_comparison$Difference) >= 0.5 * standard_devs$Pct_EL & abs(df_comparison$Difference) < standard_devs$Pct_EL, 4] = chprop(myCellProps, background.color = "yellow")
            
            comp_table[df_comparison$Characteristic == "Percent Native American" & abs(df_comparison$Difference) >= standard_devs$Pct_Native_American, 4] = chprop(myCellProps, background.color = "orange")
            comp_table[df_comparison$Characteristic == "Percent Native American" & abs(df_comparison$Difference) >= 0.5 * standard_devs$Pct_Native_American & abs(df_comparison$Difference) < standard_devs$Pct_Native_American, 4] = chprop(myCellProps, background.color = "yellow")
            
            comp_table[df_comparison$Characteristic == "Percent Hispanic" & abs(df_comparison$Difference) >= standard_devs$Pct_Hispanic, 4] = chprop(myCellProps, background.color = "orange")
            comp_table[df_comparison$Characteristic == "Percent Hispanic" & abs(df_comparison$Difference) >= 0.5 * standard_devs$Pct_Hispanic & abs(df_comparison$Difference) < standard_devs$Pct_Hispanic, 4] = chprop(myCellProps, background.color = "yellow")
            
            comp_table[df_comparison$Characteristic == "Percent Black" & abs(df_comparison$Difference) >= standard_devs$Pct_Black, 4] = chprop(myCellProps, background.color = "orange")
            comp_table[df_comparison$Characteristic == "Percent Black" & abs(df_comparison$Difference) >= 0.5 * standard_devs$Pct_Black & abs(df_comparison$Difference) < standard_devs$Pct_Black, 4] = chprop(myCellProps, background.color = "yellow")
            
        } else {
            setFlexTableWidths(comp_table, widths = c(5, 3))
        }
        
        return(comp_table)
        
    })

    output$header_comp_profile <- renderText({
        if (clicked$district == "" | clicked$district == input$district) {
            paste("District Profile Data for", input$district, sep = " ")
        } else {
            paste("District Profile Data for", input$district, "and", clicked$district, sep = " ")
        }
    })

})