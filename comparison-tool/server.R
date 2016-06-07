## District Comparison Tool
# server.R

shinyServer(function(input, output) {

    similarityData <- reactive({

        chars <- select(df_std, one_of(c("system_name", input$district_chars)))
        df2 <- chars[complete.cases(chars), ]

        similarity <- data.frame(system_name = df2[, 1], similarity_score = NA, stringsAsFactors = FALSE)

        # Compute vector of similarity scores against selected district
        for (i in 1:nrow(df2)) {

            similarity[i, 2] <- sqrt(sum((df2[i,2:ncol(df2)] - df2[which(df2$system_name == input$district), 2:ncol(df2)])^2))

        }
        
        similarity %>%
            arrange(similarity_score) %>%
            inner_join(df_outcomes, by = "system_name") %>%
            slice(1:9)
        
        })

    # Create tooltip with district name and proficiency %
    tooltip <- function(x) {
        if (is.null(x)) return(NULL)
        row <- df[df$system_name == x$system_name, ]
        
        paste0("<b>", row$system_name, "</b><br>",
               names(outcome_list)[outcome_list == input$outcome], ": ",
               row[names(row) == input$outcome])
    }
    
    # Plot
    plot <- reactive({

        # Convert subject input (string) to variable name
        yvar <- prop("y", as.symbol(input$outcome))

        similarityData() %>%
            ggvis(~system_name, yvar, key := ~system_name) %>%
            layer_bars(fill := "blue", fillOpacity := 0.3, fillOpacity.hover := 0.8) %>%
            add_axis("x", title = "District", grid = FALSE) %>%
            add_axis("y", title = "Percent Proficient or Advanced", grid = FALSE) %>%
            add_tooltip(tooltip, on = "hover") %>%
            scale_ordinal("x", domain = similarityData()$system_names) %>%
            scale_numeric("y", domain = c(0, 100)) %>%
            set_options(width = 'auto', height = 600)

    })

    plot %>% bind_shiny("plot")

    }
)