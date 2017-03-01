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
    quintile_options <- c("N/A", "19.9% or Less", "20% to 39.9%", "40% to 59.9%", "60% to 79.9%", "80% or More")
    amo_options <- c("N/A", "Regress", "Progress but do not Meet AMO Target",
        "Meet AMO Target with Confidence Interval", "Meet AMO Target", "Meet Double AMO Target")

    # Observers to show/hide appropriate inputs
    observeEvent(input$button_intro, once = TRUE, {
        show("pool", anim = TRUE)
        hide("button_intro", anim = TRUE)
    })

    observeEvent(input$eoc, {
        if (input$eoc != "") {
            show("button_pool", anim = TRUE)
        } else {
            hide("button_pool", anim = TRUE)
        }
    })

    observeEvent(input$button_pool, once = TRUE, {
        show("minimum_performance", anim = TRUE)
        hide("pool", anim = TRUE)
    })

    observeEvent(c(input$success_3yr, input$tvaas_lag), {
        if (input$success_3yr %in% c("Less than 20%", "Between 20% and 35%")) {
            show("tvaas_lag", anim = TRUE)

            if (input$tvaas_lag == ""){
                hide("button_comprehensive", anim = TRUE)
            } else {
                show("button_comprehensive", anim = TRUE)
            }

        } else if (input$success_3yr == "Above 35%") {
            show("button_comprehensive", anim = TRUE)
            hide("tvaas_lag", anim = TRUE)
        }
    })

    observeEvent(input$button_comprehensive, once = TRUE, {
        show("achievement", anim = TRUE)
        hide("minimum_performance", anim = TRUE)
    })

    # Skip Readiness for K-8 schools
    observeEvent(input$button_achievement, once = TRUE, {
        if (input$eoc == "Yes") {
            show("readiness", anim = TRUE)
            hide("done_ach", anim = TRUE)
        } else if (input$eoc == "No") {
            show("elpa", anim = TRUE)
            hide("done_ach", anim = TRUE)
        }
    })

    observeEvent(input$readiness_eligible, {
        if (input$readiness_eligible == "Yes") {
            show("readiness_table_container", anim = TRUE)
            show("done_readiness", anim = TRUE)
            hide("skip_readiness", anim = TRUE)
        } else if (input$readiness_eligible == "No") {
            hide("readiness_table_container", anim = TRUE)
            hide("done_readiness", anim = TRUE)
            show("skip_readiness", anim = TRUE)
        } else {
            hide("readiness_table_container", anim = TRUE)
            hide("done_readiness", anim = TRUE)
            hide("skip_readiness", anim = TRUE)
        }
    })

    observeEvent(input$button_readiness, once = TRUE, {
        show("elpa", anim = TRUE)
        hide("readiness_eligible", anim = TRUE)
        hide("done_readiness", anim = TRUE)
    })

    observeEvent(input$skip_readiness, once = TRUE, {
        show("elpa", anim = TRUE)
        hide("readiness", anim = TRUE)
    })

    observeEvent(input$elpa_eligible, {
        if (input$elpa_eligible == "Yes") {
            show("elpa_table_container", anim = TRUE)
            show("done_elpa", anim = TRUE)
            hide("skip_elpa", anim = TRUE)
        } else if (input$elpa_eligible == "No") {
            hide("elpa_table_container", anim = TRUE)
            hide("done_elpa", anim = TRUE)
            show("skip_elpa", anim = TRUE)
        } else {
            hide("elpa_table_container", anim = TRUE)
            hide("done_elpa", anim = TRUE)
            hide("skip_elpa", anim = TRUE)
        }
    })

    observeEvent(input$button_elpa, once = TRUE, {
        show("absenteeism", anim = TRUE)
        hide("elpa_eligible", anim = TRUE)
        hide("done_elpa", anim = TRUE)
        show("done_absenteeism", anim = TRUE)
    })

    observeEvent(input$skip_elpa, once = TRUE, {
        show("absenteeism", anim = TRUE)
        hide("elpa", anim = TRUE)
        show("done_absenteeism", anim = TRUE)
    })

    observeEvent(input$button_absenteeism, once = TRUE,  {
        show("heatmap", anim = TRUE)
        hide("done_absenteeism", anim = TRUE)
        show("done_heatmap", anim = TRUE)
    })

    observeEvent(input$button_heatmap, once = TRUE, {
        hide("done_heatmap", anim = TRUE)
        show("determinations", anim = TRUE)
    })

    # Observers/reactives to calculate grade
    output$pool_determination <- renderText(switch(input$eoc,
        "Yes" = "For accountability purposes, your school is in the <b>high school</b> grade pool.",
        "No" = "For accountability purposes, your school is in the <b>K-8</b> grade pool.")
    )

    output$comprehensive_determination <- renderText(switch(input$success_3yr,
        "Less than 20%" = switch(input$tvaas_lag,
            "No" = "<p>Your school is <b>at risk of being named a Comprehensive Support School</b>.</p>
                <p>To avoid being named a Comprehensive Support School, your school must
                perform <b>above the bottom 5 percent of schools based on a three year
                success rate</b> in 2018.</p>",
            "Yes" = "<p>Your school is <b>at risk of being named a Comprehensive Support School</b>.</p>
                <p>To avoid being named a Comprehensive Support School, your school must
                perform <b>above the bottom 5 percent of schools based on a three year
                success rate</b> OR <b>earn a TVAAS Composite Level 4 or 5</b> in 2018.</p>"),
        "Between 20% and 35%" = switch(input$tvaas_lag,
            "No" = "<p>Your school is <b>on the cusp of eligibility for Comprehensive Support</b>.</p>
                <p>To avoid being named a Comprehensive Support school, your school must
                perform <b>above the bottom 5 percent of schools based on a three year
                success rate</b> in 2018.<p>",
            "Yes" = "<p>Your school is <b>on the cusp of eligibility for Comprehensive Support</b>.</p>
                <p>To avoid being named a Comprehensive Support school, your school must
                perform <b>above the bottom 5 percent of schools based on a three year
                success rate</b> OR <b>earn a Level 4 or 5 Composite TVAAS</b> in 2018.</p>"),
        "Above 35%" = "<p>Your school is <b>unlikely to be named a Comprehensive Support School</b>.</p>")
    )

    # handsontable with inputs for success rate, TVAAS, subgroup growth
    output$achievement_table <- renderRHandsontable({

        success_pctile <- factor(c("40% to 59.9%", rep("N/A", 5)),
            levels = quintile_options, ordered = TRUE)

        success_target <- factor(c("Meet AMO Target with Confidence Interval", rep("N/A", 5)),
            levels = amo_options, ordered = TRUE)

        TVAAS <- factor(c("Level 3", rep("N/A", 5)), ordered = TRUE,
            levels = c("N/A", "Level 1", "Level 2", "Level 3", "Level 4", "Level 5"))

        subgroup_growth <- factor(c("N/A", "40% to 59.9%", rep("N/A", 4)),
            levels = quintile_options, ordered = TRUE)

        data.frame(success_pctile, success_target, TVAAS, subgroup_growth) %>%
            rhandsontable(rowHeaderWidth = 225, rowHeaders = subgroups,
                colHeaders = c("Success Rate Percentile", "Success Rate AMO Target", "TVAAS", "Subgroup Growth Percentile")) %>%
            hot_context_menu(allowColEdit = FALSE, allowRowEdit = FALSE) %>%
            hot_rows(rowHeights = 40) %>%
            hot_col(c("Success Rate Percentile", "Success Rate AMO Target", "TVAAS", "Subgroup Growth Percentile"), type = "dropdown")

    })

    # handsontable with inputs for ACT and grad rate
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

    # handsontable with inputs for ELPA
    output$elpa_table <- renderRHandsontable({

        elpa_exit <- factor(c("12% to 23.9%", "N/A", "N/A", "N/A", "12% to 23.9%", "N/A"), ordered = TRUE,
            levels = c("N/A", "5.9% or Less", "6% to 11.9%", "12% to 23.9%", "24% to 35.9%", "36% or Greater"))

        elpa_growth <- factor(c("45% to 59.9%", "N/A", "N/A", "N/A", "45% to 59.9%", "N/A"), ordered = TRUE,
            levels = c("N/A", "29.9% or Less", "30% to 44.9%", "45% to 59.9%", "60% to 69.9%", "70% or Greater"))

        data.frame(elpa_exit, elpa_growth) %>%
            rhandsontable(rowHeaderWidth = 225, rowHeaders = subgroups,
                colHeaders = c("ELPA Exit", "ELPA Met Growth Standard")) %>%
            hot_context_menu(allowColEdit = FALSE, allowRowEdit = FALSE) %>%
            hot_cols(colWidths = c(150, 150)) %>%
            hot_rows(rowHeights = 40) %>%
            hot_col(c("ELPA Exit", "ELPA Met Growth Standard"), type = "dropdown")

    })

    # handsontable with inputs for absenteeism
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

    # Convert handsontables to reactive objects
    ach <- reactive(
        input$achievement_table %>%
            hot_to_r() %>%
            as_data_frame() %>%
            mutate(Subgroup = subgroups)
    )

    readiness <- reactive(
        if (is.null(input$readiness_table) || input$readiness_eligible == "No") {
            data_frame(Subgroup = subgroups,
                readiness_abs = rep(NA, 6),
                readiness_target = rep(NA, 6))
        } else {
            input$readiness_table %>%
                hot_to_r() %>%
                as_data_frame() %>%
                mutate(Subgroup = subgroups)
        }
    )

    elpa <- reactive(
        if (is.null(input$elpa_table) || input$elpa_eligible == "No") {
            data_frame(Subgroup = subgroups,
                elpa_exit = rep(NA, 6),
                elpa_growth = rep(NA, 6))
        } else {
            input$elpa_table %>%
                hot_to_r() %>%
                as_data_frame() %>%
                mutate(Subgroup = subgroups)
        }
    )

    absenteeism <- reactive(
        input$absenteeism_table %>%
            hot_to_r() %>%
            as_data_frame() %>%
            mutate(Subgroup = subgroups)
    )

    # Calculate subgroup grades
    heat_map_metrics <- reactive(
        if (input$eoc == "No") {
            ach() %>%
                inner_join(elpa(), by = "Subgroup") %>%
                inner_join(absenteeism(), by = "Subgroup") %>%
                mutate_each(funs(as.numeric), success_pctile, success_target, TVAAS, subgroup_growth,
                    elpa_exit, elpa_growth, absenteeism_abs, absenteeism_target) %>%
                mutate_each(funs(ifelse(. == 1, NA, .)), success_pctile, success_target, TVAAS, subgroup_growth,
                    elpa_exit, elpa_growth, absenteeism_abs, absenteeism_target) %>%
                mutate_each(funs(. - 2), success_pctile, success_target, TVAAS, subgroup_growth,
                    elpa_exit, elpa_growth, absenteeism_abs, absenteeism_target) %>%
                mutate(grade_achievement = pmax(success_pctile, success_target, na.rm = TRUE),
                    grade_growth = ifelse(Subgroup == "All Students", TVAAS, subgroup_growth),
                    grade_elpa = pmax(elpa_exit, elpa_growth, na.rm = TRUE),
                    grade_absenteeism = pmax(absenteeism_abs, absenteeism_target, na.rm = TRUE),
                    weight_achievement = ifelse(!is.na(grade_achievement), 0.45, NA),
                    weight_growth = ifelse(!is.na(grade_growth), 0.35, NA),
                    weight_opportunity = ifelse(!is.na(grade_absenteeism), 0.1, NA),
                    weight_elpa = ifelse(!is.na(grade_elpa), 0.1, NA),
                    # If no ELPA, adjust achievement and growth weights accordingly
                    weight_achievement = ifelse(is.na(grade_elpa) & !is.na(grade_achievement), 0.5, weight_achievement),
                    weight_growth = ifelse(is.na(grade_elpa) & !is.na(grade_growth), 0.4, weight_growth)) %>%
                rowwise() %>%
                # Subgroup Grades
                mutate(total_weight = sum(weight_achievement, weight_growth, weight_opportunity, weight_elpa, na.rm = TRUE),
                    subgroup_average = sum(weight_achievement * grade_achievement,
                        weight_growth * grade_growth,
                        weight_opportunity * grade_absenteeism,
                        weight_elpa * grade_elpa, na.rm = TRUE)/total_weight) %>%
                ungroup()
        } else if (input$eoc == "Yes") {
            ach() %>%
                inner_join(readiness(), by = "Subgroup") %>%
                inner_join(elpa(), by = "Subgroup") %>%
                inner_join(absenteeism(), by = "Subgroup") %>%
                mutate_each(funs(as.numeric), success_pctile, success_target, TVAAS, subgroup_growth,
                    readiness_abs, readiness_target, elpa_exit, elpa_growth, absenteeism_abs, absenteeism_target) %>%
                mutate_each(funs(ifelse(. == 1, NA, .)), success_pctile, success_target, TVAAS, subgroup_growth,
                    readiness_abs, readiness_target, elpa_exit, elpa_growth, absenteeism_abs, absenteeism_target) %>%
                mutate_each(funs(. - 2), success_pctile, success_target, TVAAS, subgroup_growth,
                    readiness_abs, readiness_target, elpa_exit, elpa_growth, absenteeism_abs, absenteeism_target) %>%
                mutate(grade_achievement = pmax(success_pctile, success_target, na.rm = TRUE),
                    grade_growth = ifelse(Subgroup == "All Students", TVAAS, subgroup_growth),
                    grade_readiness = pmax(readiness_abs, readiness_target, na.rm = TRUE),
                    grade_elpa = pmax(elpa_exit, elpa_growth, na.rm = TRUE),
                    grade_absenteeism = pmax(absenteeism_abs, absenteeism_target, na.rm = TRUE),
                    weight_achievement = ifelse(!is.na(grade_achievement), 0.3, NA),
                    weight_growth = ifelse(!is.na(grade_growth), 0.25, NA),
                    weight_readiness = ifelse(!is.na(grade_readiness), 0.25, NA),
                    weight_opportunity = ifelse(!is.na(grade_absenteeism), 0.1, NA),
                    weight_elpa = ifelse(!is.na(grade_elpa), 0.1, NA),
                    # If no ELPA, adjust achievement and growth weights accordingly
                    weight_achievement = ifelse(is.na(grade_elpa) & !is.na(grade_achievement), 0.35, weight_achievement),
                    weight_growth = ifelse(is.na(grade_elpa) & !is.na(grade_growth), 0.3, weight_growth)) %>%
                rowwise() %>%
                # Subgroup Grades
                mutate(total_weight = sum(weight_achievement, weight_growth, weight_readiness, weight_opportunity, weight_elpa, na.rm = TRUE),
                    subgroup_average = sum(weight_achievement * grade_achievement,
                        weight_growth * grade_growth,
                        weight_opportunity * grade_absenteeism,
                        weight_readiness * grade_readiness,
                        weight_elpa * grade_elpa, na.rm = TRUE)/total_weight) %>%
                ungroup()
        }
    )

    output$heatmap <- renderTable(
        if (input$eoc == "Yes") {
            heat_map_metrics() %>%
                mutate_each(funs(as.character), grade_achievement, grade_growth, grade_readiness, grade_absenteeism, grade_elpa) %>%
                mutate_each(funs(recode(.,  "4" = "A", "3" = "B", "2" = "C", "1" = "D", "0" = "F")),
                    grade_achievement, grade_growth, grade_readiness, grade_absenteeism, grade_elpa) %>%
                transmute(Subgroup, `Achievement Grade` = grade_achievement,
                    `Growth Grade` = grade_growth,
                    `Readiness Grade` = grade_readiness,
                    `ELPA Grade` = grade_elpa,
                    `Absenteeism Grade` = grade_absenteeism)
        } else if (input$eoc == "No") {
            heat_map_metrics() %>%
                mutate_each(funs(as.character), grade_achievement, grade_growth, grade_absenteeism, grade_elpa) %>%
                mutate_each(funs(recode(.,  "4" = "A", "3" = "B", "2" = "C", "1" = "D", "0" = "F")),
                    grade_achievement, grade_growth, grade_absenteeism, grade_elpa) %>%
                transmute(Subgroup, `Achievement Grade` = grade_achievement,
                    `Growth Grade` = grade_growth,
                    `ELPA Grade` = grade_elpa,
                    `Absenteeism Grade` = grade_absenteeism)
        }
    )


    output$heatmap_text <- renderText(
        if (input$eoc == "Yes") {
            "<p>The <b>Achievement Grade</b> is the better of your school's grades on the
                <b>Success Rate Percentile</b> and <b>Success Rate AMO Target</b> indicators.</p>
            <p>The <b>Growth Grade</b> is detemined by <b>TVAAS</b> for All Students and by
                <b>Subgroup Growth</b> for subgroups.</p>
            <p>The <b>Readiness Grade</b> is the better of your school's grades on the
                <b>Readiness</b> and <b>Readiness AMO Target</b> indicators.</p>
            <p>The <b>ELPA Grade</b> is the better of your school's grades on the
                <b>ELPA Exit</b> and <b>ELPA Growth Standard</b> indicators.</p>
            <p>The <b>Absenteeism Grade</b> is the better of your school's grades on the
                <b>Absenteeism</b> and <b>Absenteeism Reduction AMO Target</b> indicators.</p>"
        } else if (input$eoc == "No") {
            "<p>The <b>Achievement Grade</b> is the better of your school's grades on the
                <b>Success Rate Percentile</b> and <b>Success Rate AMO Target</b> indicators.</p>
            <p>The <b>Growth Grade</b> is detemined by <b>TVAAS</b> for All Students and by
                <b>Subgroup Growth</b> for subgroups.</p>
            <p>The <b>ELPA Grade</b> is the better of your school's grades on the
                <b>ELPA Exit</b> and <b>ELPA Growth Standard</b> indicators.</p>
            <p>The <b>Absenteeism Grade</b> is the better of your school's grades on the
                <b>Absenteeism</b> and <b>Absenteeism Reduction AMO Target</b> indicators.</p>"
        }
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
            ach_determ <- "<p>Your school's final achievement grade is an F.</p>"
        } else if (ach_average <= 1) {
            ach_determ <- "<p>Your school's final achievement grade is a D.</p>"
        } else if (ach_average <= 2) {
            ach_determ <- "<p>Your school's final achievement grade is a C.</p>"
        } else if (ach_average <= 3) {
            ach_determ <- "<p>Your school's final achievement grade is a B.</p>"
        } else if (ach_average > 3) {
            ach_determ <- "<p>Your school's final achievement grade is an A.</p>"
        }

        if (gap_average == 0) {
            gap_determ <- "<p>Your school's final subgroup grade is an F.</p>"
        } else if (gap_average <= 1) {
            gap_determ <- "<p>Your school's final subgroup grade is a D.</p>"
        } else if (gap_average <= 2) {
            gap_determ <- "<p>Your school's final subgroup grade is a C.</p>"
        } else if (gap_average <= 3) {
            gap_determ <- "<p>Your school's final subgroup grade is a B.</p>"
        } else if (gap_average > 3) {
            gap_determ <- "<p>Your school's final subgroup grade is an A.</p>"
        }

        if (final_average <= 1) {
            final_determ <- "<p>Your school's overall final grade is a D.</p>"
        } else if (final_average <= 2) {
            final_determ <- "<p>Your school's overall final grade is a C.</p>"
        } else if (final_average <= 3) {
            final_determ <- "<p>Your school's overall final grade is a B.</p>"
        } else if (final_average > 3) {
            final_determ <- "<p>Your school's overall final grade is an A.</p>"
        }

        return(paste(ach_determ, gap_determ, final_determ))

    })

    }
)
