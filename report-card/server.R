## Report Card
# server.R

shinyServer(function(input, output) {

    district_determ <- reactive({
        filter(determinations, system_name == input$district)
    })

    output$table <- renderFormattable({
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

    output$header_dist <- renderText({paste("District Accountability for", input$district, sep = " ")})

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

    }
)