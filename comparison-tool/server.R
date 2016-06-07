## District Comparison Tool
# server.R

shinyServer(function(input, output) {

    similarityData <- reactive({
    
        chars <- select(df_std, one_of(c("system_name", input$district_chars)))
        df2 <- chars[complete.cases(chars), ]
        
        similarity <- data.frame(system_name = df2[, 1], similarity_score = NA, stringsAsFactors = FALSE)
        
        for (i in 1:nrow(df2)) {
            
            similarity[i, 2] <- sqrt(sum((df2[i,2:ncol(df2)] - df2[which(df2$system_name == input$district), 2:ncol(df2)])^2))
            
        }
        
        similarity %>%
            arrange(similarity_score) %>%
            inner_join(df_achievement, by = "system_name") %>%
            slice(1:9)
        
        })

    similar_district_list <- reactive({
        similarityData()$system_name  
    })

    plot <- reactive({

        # Convert subject input (string) to variable name
        yvar <- prop("y", as.symbol(input$subject))
        
        similarityData() %>%
            ggvis(~system_name, yvar) %>%
            layer_bars(fill := "blue", fillOpacity := 0.3, fillOpacity.hover := 0.8) %>%
            add_axis("x", title = "District", grid = FALSE) %>%
            add_axis("y", title = "Percent Proficient or Advanced", grid = FALSE) %>%
            scale_ordinal("x", domain = similar_district_list()) %>%
            scale_numeric("y", domain = c(0, 100)) %>%
            set_options(width = 'auto', height = 600)

    })

    plot %>% bind_shiny("plot")

    }
)