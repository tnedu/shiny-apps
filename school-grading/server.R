## School Grading Walkthrough
# server.R

library(dplyr)
library(shiny)
library(shinyjs)
library(rhandsontable)

shinyServer(function(input, output, session) {

    # Global vectors with dropdown options
    subgroups <- c("All Students", "Black/Hispanic/Native American", "Economically Disadvantaged",
        "Students with Disabilities", "English Learners", "Super Subgroup")
    quintiles <- c("N/A", "19.9% or Less", "20% to 39.9%", "40% to 59.9%", "60% to 79.9%", "80% or More")
    amo_options <- c("N/A", "Regress", "Progress but do not Meet AMO Target",
        "Meet AMO Target with Confidence Interval", "Meet AMO Target", "Meet Double AMO Target")

    # Observers to show/hide appropriate inputs
    observeEvent(input$button1, {
        show("pool", anim = TRUE)
        hide("button1", anim = TRUE)
    })

    observe(if (input$eoc != "") show("button2"))

    observeEvent(input$button2, {
        show("minimum_performance", anim = TRUE)
        hide("pool", anim = TRUE)
    })

    observe({
        if (input$success_3yr %in% c("Less than 20%", "Between 20% and 35%")) {
            show("tvaas_lag", anim = TRUE)

            if (input$tvaas_lag != ""){
                show("button3", anim = TRUE)
            }

        } else if (input$success_3yr == "Above 35%") {
            show("button3", anim = TRUE)
            hide("tvaas_lag", anim = TRUE)
        }
    })


    observeEvent(input$button3, {
        show("achievement", anim = TRUE)
        hide("minimum_performance", anim = TRUE)
    })

    observeEvent(input$button4, {
        show("readiness", anim = TRUE)
        hide("done_ach", anim = TRUE)
    })

    observe({
        if (input$readiness_eligible == "Yes") {
            show("readiness_table_container")
            show("done_readiness")
        }
    })

    observeEvent(input$button5, {
        show("elpa", anim = TRUE)
        hide("done_readiness", anim = TRUE)
    })


    observe({
        if (input$elpa_eligible == "Yes") {
            show("elpa_table_container")
            show("done_elpa")
        }
    })

    observeEvent(input$button6, {
        show("absenteeism", anim = TRUE)
        hide("done_elpa", anim = TRUE)
        show("done_absenteeism", anim = TRUE)
    })

    observeEvent(input$button7, {
        show("heatmap", anim = TRUE)
        show("determinations", anim = TRUE)
        hide("done_absenteeism", anim = TRUE)
    })

    output$pool_determination <- renderText(

        switch(input$eoc,
            "Yes" = "For accountability purposes, your school is in the <b>high school</b> grade pool.",
            "No" = "For accountability purposes, your school is in the <b>K-8</b> grade pool.")

    )

    output$comprehensive_determination <- renderText(

        switch(input$success_3yr,
            "Less than 20%" = switch(input$tvaas_lag,
                "No" = "Your school is <b>at risk of being named a Comprehensive Support School</b>.
                    To avoid being named a Comprehensive Support School, your school must
                    perform <b>above the bottom 5 percent of schools based on a three year
                    success rate</b> in 2018.",
                "Yes" = "Your school is <b>at risk of being named a Comprehensive Support School</b>.
                    To avoid being named a Comprehensive Support School, your school must
                    perform <b>above the bottom 5 percent of schools based on a three year
                    success rate</b> OR <b>earn a TVAAS Composite Level 4 or 5</b> in 2018."),
            "Between 20% and 35%" = switch(input$tvaas_lag,
                "No" = "Your school is on the cusp of eligibility for Comprehensive Support.
                    To avoid being named a Comprehensive Support school, your school must
                    perform <b>above the bottom 5 percent of schools based on a three year
                    success rate</b> in 2018.",
                "Yes" = "Your school is on the cusp of eligibility for Comprehensive Support.
                    To avoid being named a Comprehensive Support school, your school must
                    perform <b>above the bottom 5 percent of schools based on a three year
                    success rate</b> OR <b>earn a Level 4 or 5 Composite TVAAS</b> in 2018."),
            "Above 35%" = "Your school is unlikely to be named a Comprehensive Support School.")

    )

    output$achievement_table <- renderRHandsontable({

        success_abs <- factor(c("40% to 59.9%", rep("N/A", 5)),
            levels = quintiles, ordered = TRUE)

        success_target <- factor(c("Meet AMO Target with Confidence Interval", rep("N/A", 5)),
            levels = amo_options, ordered = TRUE)

        TVAAS <- factor(c("Level 3", rep("N/A", 5)), ordered = TRUE,
            levels = c("N/A", "Level 1", "Level 2", "Level 3", "Level 4", "Level 5"))

        subgroup_growth <- factor(c("N/A", "40% to 59.9%", rep("N/A", 4)),
            levels = quintiles, ordered = TRUE)

        data.frame(success_abs, success_target, TVAAS, subgroup_growth) %>%
            rhandsontable(rowHeaderWidth = 225, rowHeaders = subgroups,
                colHeaders = c("Success Rate", "Success Rate AMO Target", "TVAAS", "Subgroup Growth")) %>%
            hot_context_menu(allowColEdit = FALSE, allowRowEdit = FALSE) %>%
            hot_rows(rowHeights = 40) %>%
            hot_col(c("Success Rate", "Success Rate AMO Target", "TVAAS", "Subgroup Growth"), type = "dropdown")

    })

    output$readiness_table <- renderRHandsontable({

        readiness_abs <- factor(c("28.1% to 35%", rep("N/A", 5)), ordered = TRUE,
            levels = c("N/A", "16% or Less", "16.1% to 28%", "28.1% to 35%", "35.1% to 49.9%", "50% or Greater"))

        readiness_target <- factor(c("Meet AMO Target with Confidence Interval", rep("N/A", 5)),
            levels = amo_options, ordered = TRUE)

        data.frame(readiness_abs, readiness_target) %>%
            rhandsontable(rowHeaderWidth = 225, rowHeaders = subgroups,
                colHeaders = c("Readiness", "Readiness AMO Target")) %>%
            hot_context_menu(allowColEdit = FALSE, allowRowEdit = FALSE) %>%
            hot_cols(colWidths = c(150, 300)) %>%
            hot_rows(rowHeights = 40) %>%
            hot_col(c("Readiness", "Readiness AMO Target"), type = "dropdown")

    })

    output$elpa_table <- renderRHandsontable({

        elpa_exit <- factor(c("12% to 23.9%", rep("N/A", 5)), ordered = TRUE,
            levels = c("N/A", "5.9% or Less", "6% to 11.9%", "12% to 23.9%", "24% to 35.9%", "36% or Greater"))

        elpa_growth <- factor(c("45% to 59.9%", rep("N/A", 5)), ordered = TRUE,
            levels = c("N/A", "29.9% or Less", "30% to 44.9%", "45% to 59.9%", "60% to 69.9%", "70% or Greater"))

        data.frame(elpa_exit, elpa_growth) %>%
            rhandsontable(rowHeaderWidth = 225, rowHeaders = subgroups,
                colHeaders = c("ELPA Exit", "ELPA Met Growth Standard")) %>%
            hot_context_menu(allowColEdit = FALSE, allowRowEdit = FALSE) %>%
            hot_cols(colWidths = c(150, 150)) %>%
            hot_rows(rowHeights = 40) %>%
            hot_col(c("ELPA Exit", "ELPA Met Growth Standard"), type = "dropdown")

    })

    output$absenteeism_table <- renderRHandsontable({

        absenteeism_abs <- factor(c("12.1% to 17%", rep("N/A", 5)), ordered = TRUE,
            levels = c("N/A", "Greater than 24%", "17.1% to 24%", "12.1% to 17%", "8.1% to 12%", "8% or Less"))

        absenteeism_target <- factor(c("Meet AMO Target with Confidence Interval", rep("N/A", 5)),
            levels = amo_options, ordered = TRUE)

        data.frame(absenteeism_abs, absenteeism_target) %>%
            rhandsontable(rowHeaderWidth = 225, rowHeaders = subgroups,
                colHeaders = c("Absenteeism", "Absenteeism Reduction AMO Target")) %>%
            hot_context_menu(allowColEdit = FALSE, allowRowEdit = FALSE) %>%
            hot_cols(colWidths = c(150, 300)) %>%
            hot_rows(rowHeights = 40) %>%
            hot_col(c("Absenteeism", "Absenteeism Reduction AMO Target"), type = "dropdown")

    })

    heat_map_metrics <- reactive({

        req(input$achievement_table, input$readiness_table, input$elpa_table, input$absenteeism_table)

        ach <- hot_to_r(input$achievement_table) %>% as_data_frame()
        ach$Subgroup <- subgroups

        readiness <- hot_to_r(input$readiness_table) %>% as_data_frame()
        readiness$Subgroup <- subgroups

        elpa <- hot_to_r(input$elpa_table) %>% as_data_frame()
        elpa$Subgroup <- subgroups

        absenteeism <- hot_to_r(input$absenteeism_table) %>% as_data_frame()
        absenteeism$Subgroup <- subgroups

        ach %>%
            inner_join(readiness, by = "Subgroup") %>%
            inner_join(elpa, by = "Subgroup") %>%
            inner_join(absenteeism, by = "Subgroup") %>%
            mutate_each(funs(as.numeric), success_abs, success_target, TVAAS, subgroup_growth,
                readiness_abs, readiness_target, elpa_exit, elpa_growth, absenteeism_abs, absenteeism_target) %>%
            mutate_each(funs(ifelse(. == 1, NA, .)), success_abs, success_target, TVAAS, subgroup_growth,
                readiness_abs, readiness_target, elpa_exit, elpa_growth, absenteeism_abs, absenteeism_target) %>%
            mutate_each(funs(. - 2), success_abs, success_target, TVAAS, subgroup_growth,
                readiness_abs, readiness_target, elpa_exit, elpa_growth, absenteeism_abs, absenteeism_target) %>%
            mutate(pool = ifelse(input$eoc == "Yes", "HS", "K8"),
                grade_achievement = pmax(success_abs, success_target, na.rm = TRUE),
                grade_tvaas = TVAAS,
                grade_growth = subgroup_growth,
                grade_readiness = pmax(readiness_abs, readiness_target, na.rm = TRUE),
                grade_elpa = pmax(elpa_exit, elpa_growth, na.rm = TRUE),
                grade_absenteeism = pmax(absenteeism_abs, absenteeism_target, na.rm = TRUE)) %>%
            mutate(
                weight_achievement = ifelse(!is.na(grade_achievement) & pool == "K8", 0.45, NA),
                weight_achievement = ifelse(!is.na(grade_achievement) & pool == "HS", 0.3, weight_achievement),
                weight_growth = ifelse(!is.na(grade_tvaas) & pool == "K8", 0.35, NA),
                weight_growth = ifelse(!is.na(grade_growth) & pool == "K8", 0.35, weight_growth),
                weight_growth = ifelse(!is.na(grade_tvaas) & pool == "HS", 0.25, weight_growth),
                weight_growth = ifelse(!is.na(grade_growth) & pool == "HS", 0.25, weight_growth),
                weight_readiness = ifelse(!is.na(grade_readiness) & pool == "HS", 0.25, NA),
                weight_opportunity = ifelse(!is.na(grade_absenteeism), 0.1, NA),
                weight_elpa = ifelse(!is.na(grade_elpa), 0.1, NA),
                # If no ELPA, adjust achievement and growth weights accordingly
                weight_achievement = ifelse(is.na(grade_elpa) & !is.na(grade_achievement) & pool == "K8", 0.5, weight_achievement),
                weight_achievement = ifelse(is.na(grade_elpa) & !is.na(grade_achievement) & pool == "HS", 0.35, weight_achievement),
                weight_growth = ifelse(is.na(grade_elpa) & !is.na(grade_tvaas) & pool == "K8", 0.4, weight_growth),
                weight_growth = ifelse(is.na(grade_elpa) & !is.na(grade_growth) & pool == "K8", 0.4, weight_growth),
                weight_growth = ifelse(is.na(grade_elpa) & !is.na(grade_tvaas) & pool == "HS", 0.3, weight_growth),
                weight_growth = ifelse(is.na(grade_elpa) & !is.na(grade_growth) & pool == "HS", 0.3, weight_growth)) %>%
            rowwise() %>%
            # Subgroup Grades
            mutate(total_weight = sum(weight_achievement, weight_growth, weight_opportunity, weight_readiness, weight_elpa, na.rm = TRUE),
                subgroup_average = sum(weight_achievement * grade_achievement,
                    weight_growth * grade_tvaas,
                    weight_growth * grade_growth,
                    weight_opportunity * grade_absenteeism,
                    weight_readiness * grade_readiness,
                    weight_elpa * grade_elpa, na.rm = TRUE)/total_weight) %>%
            ungroup()

    })

    output$heat_map <- renderTable(

        heat_map_metrics() %>%
            transmute(Subgroup, `Achievement Points` = grade_achievement,
                `Growth Points` = grade_growth,
                `Readiness Points` = grade_readiness,
                `Absenteeism Points` = grade_absenteeism,
                `ELPA Points` = grade_elpa)

    )

    output$determinations <- renderText({

        ach_average <- heat_map_metrics() %>%
            filter(Subgroup == "All Students") %>%
            select(subgroup_average)

        gap_average <- heat_map_metrics() %>%
            filter(Subgroup != "All Students") %>%
            # Drop Super Subgroup observation if other subgroups are present
            mutate(temp = !is.na(subgroup_average),
                   subgroups_count = sum(temp, na.rm = TRUE)) %>%
            filter(!(Subgroup == "Super Subgroup" & subgroups_count > 1)) %>%
            mutate(numerator = total_weight * subgroup_average) %>%
            summarise_each(funs(sum(., na.rm = TRUE)), total_weight, numerator) %>%
            transmute(gap_closure_average = numerator/total_weight)

        if (!is.null(ach_average) & !is.null(gap_average)) {
            final_average <- 0.6 * ach_average + 0.4 * gap_average
        } else if (!is.null(ach_average) & is.null(gap_average)) {
            final_average <- ach_average
        } else if (is.null(ach_average) & !is.null(gap_average)) {
            final_average <- gap_average
        }

        if (ach_average == 0) {
            ach_determ <- "Your school's final achievement grade is an <b>F</b>."
        } else if (ach_average <= 1) {
            ach_determ <- "Your school's final achievement grade is a <b>D</b>."
        } else if (ach_average <= 2) {
            ach_determ <- "Your school's final achievement grade is a <b>C</b>."
        } else if (ach_average <= 3) {
            ach_determ <- "Your school's final achievement grade is a <b>B</b>."
        } else if (ach_average > 3) {
            ach_determ <- "Your school's final achievement grade is an <b>A</b>."
        }

        if (gap_average == 0) {
            gap_determ <- "Your school's final subgroup grade is an <b>F</b>."
        } else if (gap_average <= 1) {
            gap_determ <- "Your school's final subgroup grade is a <b>D</b>."
        } else if (gap_average <= 2) {
            gap_determ <- "Your school's final subgroup grade is a <b>C</b>."
        } else if (gap_average <= 3) {
            gap_determ <- "Your school's final subgroup grade is a <b>B</b>."
        } else if (gap_average > 3) {
            gap_determ <- "Your school's final subgroup grade is an <b>A</b>."
        }

        if (final_average <= 1) {
            final_determ <- "Your school's final grade is a <b>D</b>."
        } else if (final_average <= 2) {
            final_determ <- "Your school's final grade is a <b>C</b>."
        } else if (final_average <= 3) {
            final_determ <- "Your school's final grade is a <b>B</b>."
        } else if (final_average > 3) {
            final_determ <- "Your school's final grade is an <b>A</b>."
        }

        return(paste(sep = "<br><br>",
            ach_determ,
            gap_determ,
            final_determ))

    })

    output$achievement_determination <- renderText({

        ach_average <- heat_map_metrics() %>%
            filter(Subgroup == "All Students") %>%
            select(subgroup_average)

    })

    output$subgroup_determination <- renderText({

        gap_average <- heat_map_metrics() %>%
            filter(Subgroup != "All Students") %>%
            # Drop Super Subgroup observation if other subgroups are present
            mutate(temp = !is.na(subgroup_average),
                subgroups_count = sum(temp, na.rm = TRUE)) %>%
            filter(!(Subgroup == "Super Subgroup" & subgroups_count > 1)) %>%
            mutate(numerator = total_weight * subgroup_average) %>%
            summarise_each(funs(sum(., na.rm = TRUE)), total_weight, numerator) %>%
            transmute(gap_closure_average = numerator/total_weight)

        if (gap_average == 0) {
            "Your school's final subgroup grade is an <b>F</b>"
        } else if (gap_average <= 1) {
            "Your school's final subgroup grade is a <b>D</b>"
        } else if (gap_average <= 2) {
            "Your school's final subgroup grade is a <b>C</b>"
        } else if (gap_average <= 3) {
            "Your school's final subgroup grade is a <b>B</b>"
        } else if (gap_average > 3) {
            "Your school's final subgroup grade is an <b>A</b>"
        }

    })

    }
)
