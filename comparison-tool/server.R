## District Comparison Tool
# server.R

shinyServer(function(input, output) {

    # Identify most similar districts based on vector of selected characteristics
    similarityData <- reactive({

        req(input$district_chars)

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
            add_tooltip(tooltip, on = "hover") %>%
            scale_ordinal("x", domain = similarityData()$system_name) %>%
            scale_numeric("y", domain = y_scale) %>%
            set_options(width = 'auto', height = 600) %>%
            handle_click(click_district)

    })

    plot_prof %>% bind_shiny("plot_prof")

    output$header <- renderText({paste(names(outcome_list[outcome_list == input$outcome]), 
                                          "for districts most similar to", input$district, sep = " ")})

    # Table with profile data for selected, clicked districts
    comparisonTable <- reactive({

        df_comparison <- df_chars %>%
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

        order <- c("Enrollment", "Per-Pupil Expenditures", "Percent Economically Disadvantaged", 
                   "Percent Students with Disabilities", "Percent English Learners", "Percent Black",
                   "Percent Hispanic", "Percent Native American")
        df_comparison <- df_comparison[match(order, df_comparison$Characteristic), ]
        rownames(df_comparison) <- NULL

        return(df_comparison)

    })

    output$table <- renderFormattable({
        formattable(comparisonTable(), list(
            Difference = formatter("span", style = x ~ style(color = ifelse(x > 0, "green", "red")),
                                   x ~ sprintf("%.1f", x))
        ))
    })

    output$header2 <- renderText({
        if (clicked$district == "" | clicked$district == input$district) {
            paste("District Profile Data for", input$district, sep = " ")
        } else {
            paste("District Profile Data for", input$district, "and", clicked$district, sep = " ")
        }
    })

    }
)