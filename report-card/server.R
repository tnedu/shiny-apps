## Report Card
# server.R

shinyServer(function(input, output) {
    
    district_determ <- reactive({
        filter(determinations, system_name == input$district)
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