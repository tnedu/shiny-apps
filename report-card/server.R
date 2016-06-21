## Report Card
# server.R

shinyServer(function(input, output) {

    output$header_dist <- renderText({paste("District Accountability for", input$district, sep = " ")})
    
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

    output$ach_heatmap <- renderFlexTable({

        ach_data <- achievement %>%
            arrange(system, grade, desc(subject)) %>%
            filter(system_name == input$district) %>%
            select(one_of(c("subject", "achievement_goal", "tvaas_goal", "best_score"))) %>%
            rename("Content Area" = subject, "Achievement Goal" = achievement_goal, "TVAAS Goal" = tvaas_goal, "Best Score" = best_score)

        ach_table <- FlexTable(data = ach_data, header.par.props = parProperties(text.align = "center"), body.par.props = parProperties(text.align = "center"))
        ach_table <- setFlexTableWidths(ach_table, widths = c(3, 2, 2, 2))

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
        
        ach_table = addFooterRow(ach_table, value = c("Achievement Score", paste(sprintf("%.1f", mean(ach_data$`Best Score`, na.rm = TRUE)))),
                                colspan = c(1, 3))
        ach_table = addFooterRow(ach_table, value = c("Achievement Determination", paste(district_determ()$achievement_determination)),
                                 colspan = c(1, 3))

        return(ach_table)

    })

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

})