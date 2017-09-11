## School Grading Walkthrough
# server.R

function(input, output, session) {

    # Global vectors with dropdown options
    subgroups <- c("All Students", "Black/Hispanic/Native American", "Economically Disadvantaged",
        "Students with Disabilities", "English Learners", "Super Subgroup")
    quintile_options <- c("N/A", "19.9% or Less", "20 to 39.9%", "40 to 59.9%", "60 to 79.9%", "80% or More")
    amo_options <- c("N/A", "Regress", "Progress but do not Meet Target",
        "Meet Target with Confidence Interval", "Meet Target", "Meet Double Target")

    # Observers to show/hide appropriate inputs
    observeEvent(input$button_intro, once = TRUE, {
        show("minimum_performance", anim = TRUE)
        hide("intro", anim = TRUE)
    })

    observeEvent(c(input$success_3yr, input$tvaas_lag), {
        if (input$success_3yr %in% c("Less than 20%", "Between 20 and 35%")) {
            show("tvaas_lag", anim = TRUE)

            if (input$tvaas_lag == "") {
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

    observeEvent(input$button_achievement, once = TRUE, {
        show("readiness", anim = TRUE)
        hide("done_ach", anim = TRUE)
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
    output$comprehensive_determination <- renderText(
        switch(input$success_3yr,
            "Less than 20%" = switch(input$tvaas_lag,
                "No" = "<p>Your school is <b>at risk of being named a Comprehensive Support School</b>.</p>
                    <p>To avoid being named a Comprehensive Support School, your school must
                    perform <b>above the bottom 5 percent of schools based on a three year
                    success rate</b> in 2018.</p>",
                "Yes" = "<p>Your school is <b>at risk of being named a Comprehensive Support School</b>.</p>
                    <p>To avoid being named a Comprehensive Support School, your school must
                    perform <b>above the bottom 5 percent of schools based on a three year
                    success rate</b> OR <b>earn a TVAAS Composite Level 4 or 5</b> in 2018.</p>"),
            "Between 20 and 35%" = switch(input$tvaas_lag,
                "No" = "<p>Your school is <b>on the cusp of eligibility for Comprehensive Support</b>.</p>
                    <p>To avoid being named a Comprehensive Support school, your school must
                    perform <b>above the bottom 5 percent of schools based on a three year
                    success rate</b> in 2018.<p>",
                "Yes" = "<p>Your school is <b>on the cusp of eligibility for Comprehensive Support</b>.</p>
                    <p>To avoid being named a Comprehensive Support school, your school must
                    perform <b>above the bottom 5 percent of schools based on a three year
                    success rate</b> OR <b>earn a Level 4 or 5 Composite TVAAS</b> in 2018.</p>"),
            "Above 35%" = "<p>Your school is <b>unlikely to be named a Comprehensive Support School</b>.</p>"
        )
    )

    # Inputs for success rate, TVAAS, subgroup growth
    output$achievement_table <- renderRHandsontable({

        ## Values are just a placeholder for now until cutoffs are decided
        success_rate <- factor(c("30 to 39.9%", rep("N/A", 5)),
            levels = c("N/A", "0 to 19.9%", "20 to 29.9%", "30 to 39.9%", "40 to 49.9%", "50% or Greater"), ordered = TRUE)

        success_target <- factor(c("Meet Target with Confidence Interval", rep("N/A", 5)),
            levels = amo_options, ordered = TRUE)

        TVAAS <- factor(c("Level 3", rep("N/A", 5)), ordered = TRUE,
            levels = c("N/A", "Level 1", "Level 2", "Level 3", "Level 4", "Level 5"))

        subgroup_growth <- factor(c("N/A", "40 to 59.9%", rep("N/A", 4)),
            levels = quintile_options, ordered = TRUE)

        data.frame(success_rate, success_target, TVAAS, subgroup_growth) %>%
            rhandsontable(rowHeaderWidth = 225, rowHeaders = subgroups,
                colHeaders = c("Success Rate", "Success Rate Target", "TVAAS", "Subgroup Growth Percentile")) %>%
            hot_context_menu(allowColEdit = FALSE, allowRowEdit = FALSE) %>%
            hot_rows(rowHeights = 40) %>%
            hot_col(c("Success Rate", "Success Rate Target", "TVAAS", "Subgroup Growth Percentile"), type = "dropdown")

    })

    # Inputs for ACT and grad
    output$readiness_table <- renderRHandsontable({

        grad_abs <- factor(c("80 to 89.9%", rep("N/A", 5)), ordered = TRUE,
            levels = c("N/A", "66.9% or Less", "67 to 79.9%", "80 to 89.9%", "90 to 94.9%", "95% or Greater"))

        grad_target <- factor(c("Meet Target with Confidence Interval", rep("N/A", 5)),
            levels = amo_options, ordered = TRUE)

        readiness_abs <- factor(c("30 to 39.9%", rep("N/A", 5)), ordered = TRUE,
            levels = c("N/A", "25% or Less", "25.1 to 29.9%", "30 to 39.9%", "40 to 49.9%", "50% or Greater"))

        readiness_target <- factor(c("Meet Target with Confidence Interval", rep("N/A", 5)),
            levels = amo_options, ordered = TRUE)

        data.frame(grad_abs, grad_target, readiness_abs, readiness_target) %>%
            rhandsontable(rowHeaderWidth = 225, rowHeaders = subgroups,
                colHeaders = c("Graduation Rate", "Graduation Rate Target", "Readiness", "Readiness Target")) %>%
            hot_context_menu(allowColEdit = FALSE, allowRowEdit = FALSE) %>%
            hot_rows(rowHeights = 40) %>%
            hot_col(c("Graduation Rate", "Graduation Rate Target", "Readiness", "Readiness Target"), type = "dropdown")

    })

    # Inputs for ELPA
    output$elpa_table <- renderRHandsontable({

        elpa_exit <- factor(c("12 to 23.9%", "N/A", "N/A", "N/A", "12 to 23.9%", "N/A"), ordered = TRUE,
            levels = c("N/A", "5.9% or Less", "6 to 11.9%", "12 to 23.9%", "24 to 35.9%", "36% or Greater"))

        elpa_growth <- factor(c("45 to 59.9%", "N/A", "N/A", "N/A", "45 to 59.9%", "N/A"), ordered = TRUE,
            levels = c("N/A", "29.9% or Less", "30 to 44.9%", "45 to 59.9%", "60 to 69.9%", "70% or Greater"))

        data.frame(elpa_exit, elpa_growth) %>%
            rhandsontable(rowHeaderWidth = 225, rowHeaders = subgroups,
                colHeaders = c("ELPA Exit", "ELPA Met Growth Standard")) %>%
            hot_context_menu(allowColEdit = FALSE, allowRowEdit = FALSE) %>%
            hot_cols(colWidths = c(200, 200)) %>%
            hot_rows(rowHeights = 40) %>%
            hot_col(c("ELPA Exit", "ELPA Met Growth Standard"), type = "dropdown")

    })

    # Inputs for absenteeism
    output$absenteeism_table <- renderRHandsontable({

        absenteeism_abs <- factor(c("12.1 to 17%", rep("N/A", 5)), ordered = TRUE,
            levels = c("N/A", "Greater than 24%", "17.1 to 24%", "12.1 to 17%", "8.1 to 12%", "8% or Less"))

        absenteeism_target <- factor(c("Meet Target with Confidence Interval", rep("N/A", 5)),
            levels = amo_options, ordered = TRUE)

        data.frame(absenteeism_abs, absenteeism_target) %>%
            rhandsontable(rowHeaderWidth = 225, rowHeaders = subgroups,
                colHeaders = c("Absenteeism", "Absenteeism Reduction Target")) %>%
            hot_context_menu(allowColEdit = FALSE, allowRowEdit = FALSE) %>%
            hot_cols(colWidths = c(150, 300)) %>%
            hot_rows(rowHeights = 40) %>%
            hot_col(c("Absenteeism", "Absenteeism Reduction Target"), type = "dropdown")

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
                grad_abs = factor(rep(NA, 6)),
                grad_target = factor(rep(NA, 6)),
                readiness_abs = factor(rep(NA, 6)),
                readiness_target = factor(rep(NA, 6)))
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
                elpa_exit = factor(rep(NA, 6)),
                elpa_growth = factor(rep(NA, 6)))
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
    heat_map <- reactive({

        grades <- ach() %>%
            inner_join(readiness(), by = "Subgroup") %>%
            inner_join(elpa(), by = "Subgroup") %>%
            inner_join(absenteeism(), by = "Subgroup") %>%
            mutate_at(c("success_rate", "success_target", "TVAAS", "subgroup_growth",
                "grad_abs", "grad_target", "readiness_abs", "readiness_target",
                "elpa_exit", "elpa_growth", "absenteeism_abs", "absenteeism_target"),
                funs(if_else(as.numeric(.) == 1, NA_real_, as.numeric(.) - 2))) %>%
        # Not setting na.rm = TRUE so that schools are only evaluated if they have absolute and target grades
            mutate(grade_achievement = pmax(success_rate, success_target),
                grade_growth = if_else(Subgroup == "All Students", TVAAS, subgroup_growth),
                grade_grad = pmax(grad_abs, grad_target),
                grade_readiness = pmax(readiness_abs, readiness_target),
                grade_elpa = pmax(elpa_exit, elpa_growth),
                grade_absenteeism = pmax(absenteeism_abs, absenteeism_target))

        if (input$readiness_eligible == "Yes") {
            weights <- grades %>%
                mutate(weight_achievement = if_else(!is.na(grade_achievement), 0.3, NA_real_),
                    weight_growth = if_else(!is.na(grade_growth), 0.25, NA_real_),
                    weight_grad = if_else(!is.na(grade_grad), 0.05, NA_real_),
                    weight_readiness = if_else(!is.na(grade_readiness), 0.2, NA_real_),
                    weight_opportunity = if_else(!is.na(grade_absenteeism), 0.1, NA_real_),
                    weight_elpa = if_else(!is.na(grade_elpa), 0.1, NA_real_),
                # If no ELPA, adjust achievement and growth weights accordingly
                    weight_achievement = if_else(is.na(grade_elpa) & !is.na(grade_achievement), 0.35, weight_achievement),
                    weight_growth = if_else(is.na(grade_elpa) & !is.na(grade_growth), 0.3, weight_growth))
        } else if (input$readiness_eligible == "No") {
            weights <- grades %>%
                mutate(weight_achievement = if_else(!is.na(grade_achievement), 0.45, NA_real_),
                    weight_growth = if_else(!is.na(grade_growth), 0.35, NA_real_),
                    weight_grad = NA_real_,
                    weight_readiness = NA_real_,
                    weight_opportunity = if_else(!is.na(grade_absenteeism), 0.1, NA_real_),
                    weight_elpa = if_else(!is.na(grade_elpa), 0.1, NA_real_),
                # If no ELPA, adjust achievement and growth weights accordingly
                    weight_achievement = if_else(is.na(grade_elpa) & !is.na(grade_achievement), 0.5, weight_achievement),
                    weight_growth = if_else(is.na(grade_elpa) & !is.na(grade_growth), 0.4, weight_growth))
        }

        weights %>%
            rowwise() %>%
            mutate(total_weight = sum(weight_achievement, weight_growth, weight_grad, weight_readiness, weight_opportunity, weight_elpa, na.rm = TRUE),
                subgroup_average = round(sum(weight_achievement * grade_achievement,
                    weight_growth * grade_growth,
                    weight_opportunity * grade_absenteeism,
                    weight_grad * grade_grad,
                    weight_readiness * grade_readiness,
                    weight_elpa * grade_elpa, na.rm = TRUE)/total_weight), 2) %>%
            ungroup()

    })

    output$heatmap <- renderTable(
        heat_map() %>%
            mutate_at(c("grade_achievement", "grade_growth", "grade_grad", "grade_readiness", "grade_absenteeism", "grade_elpa"), as.numeric) %>%
            mutate_at(c("grade_achievement", "grade_growth", "grade_grad", "grade_readiness", "grade_absenteeism", "grade_elpa"),
                funs(recode(.,  "4" = "A", "3" = "B", "2" = "C", "1" = "D", "0" = "F"))) %>%
            transmute(Subgroup,
                `Achievement Grade` = grade_achievement,
                `Growth Grade` = grade_growth,
                `Graduation Rate Grade` = grade_grad,
                `Readiness Grade` = grade_readiness,
                `ELPA Grade` = grade_elpa,
                `Absenteeism Grade` = grade_absenteeism)
    )

    output$final_grades <- renderTable(width = '100%', {

        ach_average <- heat_map() %>%
            filter(Subgroup == "All Students") %>%
            magrittr::extract2("subgroup_average")

        gap_average <- heat_map() %>%
            filter(Subgroup != "All Students") %>%
        # Drop Super Subgroup if other subgroups are present
            mutate(temp = !is.na(subgroup_average),
                subgroups_count = sum(temp, na.rm = TRUE)) %>%
            filter(!(Subgroup == "Super Subgroup" & subgroups_count > 1)) %>%
            mutate(subgroup_average_weighted = total_weight * subgroup_average) %>%
            summarise_at(c("total_weight", "subgroup_average_weighted"), sum, na.rm = TRUE) %>%
            transmute(gap_average = round(subgroup_average_weighted/total_weight, 2)) %>%
            magrittr::extract2("gap_average")

        final_average <- case_when(
            !is.na(ach_average) & !is.na(gap_average) ~ round(0.6 * ach_average + 0.4 * gap_average, 2),
            !is.na(ach_average) & is.na(gap_average) ~ round(ach_average, 2),
            is.na(ach_average) & !is.na(gap_average) ~ round(gap_average, 2)
        )

        ach_grade <- case_when(
            is.na(ach_average) ~ NA_character_,
            ach_average > 3 ~ "A",
            ach_average > 2 ~ "B",
            ach_average > 1 ~ "C",
            ach_average > 0 ~ "D",
            ach_average == 0 ~ "F"
        )

        gap_grade <- case_when(
            is.na(gap_average) ~ NA_character_,
            gap_average > 3 ~ "A",
            gap_average > 2 ~ "B",
            gap_average > 1 ~ "C",
            gap_average > 0 ~ "D",
            gap_average == 0 ~ "F"
        )

        final_grade <- case_when(
            is.na(final_average) ~ NA_character_,
            final_average > 3 ~ "A",
            final_average > 2 ~ "B",
            final_average > 1 ~ "C",
            final_average > 0 ~ "D"
        )

        tibble::tribble(~` `, ~Achievement, ~Subgroup, ~Final,
            "Average", ach_average, gap_average, final_average,
            "Grade", ach_grade, gap_grade, final_grade
        )

    })

}
