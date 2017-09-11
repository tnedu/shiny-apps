## School Grading Walkthrough
# server.R

function(input, output, session) {

    # Global vector for subgroups
    subgroups <- c("All Students", "Black/Hispanic/Native American", "Economically Disadvantaged",
        "Students with Disabilities", "English Learners", "Super Subgroup")

    # Observers to show/hide appropriate inputs
    observeEvent(input$button_intro, once = TRUE, {
        show("minimum_performance", anim = TRUE)
        hide("intro", anim = TRUE)
    })

    observeEvent(c(input$success_3yr, input$tvaas_lag), {
        if (input$success_3yr %in% c("Less than 20%", "Between 20 and 35%")) {
            show("tvaas_lag", anim = TRUE)

            if (input$tvaas_lag == "") {
                hide("button_priority", anim = TRUE)
            } else {
                show("button_priority", anim = TRUE)
            }

        } else if (input$success_3yr == "Above 35%") {
            show("button_priority", anim = TRUE)
            hide("tvaas_lag", anim = TRUE)
        }
    })

    observeEvent(input$button_priority, once = TRUE, {
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
    output$priority_determination <- renderText(
        switch(input$success_3yr,
            "Less than 20%" = switch(input$tvaas_lag,
                "No" = "<p>Your school is <b>at risk of being named a Priority (F) School</b>.</p>
                    <p>To avoid being named a Priority School, your school must perform
                    <b>above the bottom 5 percent of schools based on a three year success rate</b>
                    in 2018.</p>",
                "Yes" = "<p>Your school is <b>at risk of being named a Priority (F) School</b>.</p>
                    <p>To avoid being named a Priority School, your school must perform
                    <b>above the bottom 5 percent of schools based on a three year success rate</b>
                    OR <b>earn a TVAAS Composite Level 4 or 5</b> in 2018.</p>"),
            "Between 20 and 35%" = switch(input$tvaas_lag,
                "No" = "<p>Your school is <b>on the cusp of eligibility for Priority (F School) Status</b>.</p>
                    <p>To avoid being named a Priority school, your school must perform
                    <b>above the bottom 5 percent of schools based on a three year success rate</b>
                    in 2018.<p>",
                "Yes" = "<p>Your school is <b>on the cusp of eligibility for Priority (F School) Status</b>.</p>
                    <p>To avoid being named a Priority school, your school must perform
                    <b>above the bottom 5 percent of schools based on a three year success rate</b>
                    OR <b>earn a Level 4 or 5 Composite TVAAS</b> in 2018.</p>"),
            "Above 35%" = "<p>Your school is <b>unlikely to be named a Priority (F) School</b>.</p>"
        )
    )

    # Inputs for success rate, TVAAS, subgroup growth
    output$achievement_table <- renderRHandsontable({

        success_rate <- factor(c("One-year success rate is greater than or equal to 30% but less than 40%", rep("N/A", 5)),
            levels = c("N/A",
                "One-year success rate is less than 20%",
                "One-year success rate is greater than or equal to 20% but less than 30%",
                "One-year success rate is greater than or equal to 30% but less than 40%",
                "One-year success rate is greater than or equal to 40% and less than 50%",
                "One-year success rate is greater or equal to 50%"), ordered = TRUE)

        success_target <- factor(c("Upper bound of one-year success rate confidence interval equals or exceeds AMO target", rep("N/A", 5)),
            levels = c("N/A",
                "Upper bound of one-year success rate confidence interval is less than or equal to prior one-year success rate",
                "Upper bound of one-year success rate confidence interval exceeds prior one-year success rate",
                "Upper bound of one-year success rate confidence interval equals or exceeds AMO target",
                "One-year success rate exceeds AMO target",
                "One-year success rate exceeds double AMO target"), ordered = TRUE)

        TVAAS <- factor(c("Level 3", rep("N/A", 5)), ordered = TRUE,
            levels = c("N/A", "Level 1", "Level 2", "Level 3", "Level 4", "Level 5"))

        subgroup_growth <- factor(c("N/A", "Subgroup growth is better than that of 40 percent of schools", rep("N/A", 4)),
            levels = c("N/A",
                "Subgroup growth is in the bottom 20 percent of schools",
                "Subgroup growth is better than that of 20 percent of schools",
                "Subgroup growth is better than that of 40 percent of schools",
                "Subgroup growth is better than that of 60 percent of schools",
                "Subgroup growth is better than that of 80 percent of schools"), ordered = TRUE)

        data.frame(success_rate, success_target, TVAAS, subgroup_growth) %>%
            rhandsontable(rowHeaderWidth = 225, rowHeaders = subgroups,
                colHeaders = c("Success Rate", "Success Rate Target", "TVAAS", "Subgroup Growth")) %>%
            hot_context_menu(allowColEdit = FALSE, allowRowEdit = FALSE) %>%
            hot_cols(colWidths = c(200, 200, 100, 200)) %>%
            hot_rows(rowHeights = 40) %>%
            hot_col(c("Success Rate", "Success Rate Target", "TVAAS", "Subgroup Growth"), type = "dropdown")

    })

    # Inputs for graduation rate
    output$grad_table <- renderRHandsontable({

        grad_abs <- factor(c("80% to less than 90% of students in graduating cohort graduate on-time", rep("N/A", 5)),
            levels = c("N/A",
                "Less than 67% of students in graduating cohort graduate on time",
                "67% to less than 80% of students in graduating cohort graduate on time",
                "80% to less than 90% of students in graduating cohort graduate on time",
                "90% to less than 95% of students in graduating cohort graduate on time",
                "95% or more of students in graduating cohort graduate on time"), ordered = TRUE)

        grad_target <- factor(c("Upper bound of Graduation Rate confidence interval equals or exceeds AMO target", rep("N/A", 5)),
            levels = c("N/A",
                "Upper bound of Graduation Rate confidence interval is less than or equal to prior year Graduation Rate",
                "Upper bound of Graduation Rate confidence interval exceeds prior Graduation Rate",
                "Upper bound of Graduation Rate confidence interval equals or exceeds AMO target",
                "Graduation Rate exceeds AMO target",
                "Graduation Rate exceeds double AMO target"), ordered = TRUE)

        data.frame(grad_abs, grad_target) %>%
            rhandsontable(rowHeaderWidth = 225, rowHeaders = subgroups,
                colHeaders = c("Graduation Rate", "Graduation Rate Target")) %>%
            hot_context_menu(allowColEdit = FALSE, allowRowEdit = FALSE) %>%
            hot_cols(colWidths = c(350, 350)) %>%
            hot_rows(rowHeights = 40) %>%
            hot_col(c("Graduation Rate", "Graduation Rate Target"), type = "dropdown")

    })

    # Inputs for ACT and grad
    output$readiness_table <- renderRHandsontable({

        readiness_abs <- factor(c("30% to less than 40% of graduates score a 21+ on the ACT", rep("N/A", 5)),
            levels = c("N/A",
                "Less than 25% of graduates score a 21+ on the ACT",
                "25% to less than 30% of graduates score a 21+ on the ACT",
                "30% to less than 40% of graduates score a 21+ on the ACT",
                "40% to less than 50% of graduates score a 21+ on the ACT",
                "50% or more of graduates score a 21+ on the ACT"), ordered = TRUE)

        readiness_target <- factor(c("Upper bound of Ready Graduates confidence interval equals or exceeds AMO target", rep("N/A", 5)),
            levels = c("N/A",
                "Upper bound of Ready Graduates confidence interval is less than or equal to prior year Ready Graduates",
                "Upper bound of Ready Graduates confidence interval exceeds prior Ready Graduates",
                "Upper bound of Ready Graduates confidence interval equals or exceeds AMO target",
                "Ready Graduates exceeds AMO target",
                "Ready Graduates exceeds double AMO target"), ordered = TRUE)

        data.frame(readiness_abs, readiness_target) %>%
            rhandsontable(rowHeaderWidth = 225, rowHeaders = subgroups,
                colHeaders = c("Readiness", "Readiness Target")) %>%
            hot_context_menu(allowColEdit = FALSE, allowRowEdit = FALSE) %>%
            hot_cols(colWidths = c(350, 350)) %>%
            hot_rows(rowHeights = 40) %>%
            hot_col(c("Readiness", "Readiness Target"), type = "dropdown")

    })

    # Table to show ELPA Growth Standard
    output$elpa_growth_standard <- renderTable(
        tibble::tribble(~`Prior Year ELP Range`, ~`Growth Standard`,
            "1.0 - 1.4", "1.3",
            "1.5 - 1.9", "0.7",
            "2.0 - 2.4", "0.8",
            "2.5 - 2.9", "0.7",
            "3.0 - 3.4", "0.4",
            "3.5 - 3.9", "0.5",
            "4.0 - 4.4", "0.4")
    )

    # Inputs for ELPA
    output$elpa_table <- renderRHandsontable({

        elpa_growth <- factor(c("40% to less than 50% of students meet growth standards", "N/A", "N/A", "N/A",
                "40% to less than 50% of students meet growth standards", "N/A"),
            levels = c("N/A",
                "Less than 25% of students meet growth standards",
                "25% to less than 40% of students meet growth standards",
                "40% to less than 50% of students meet growth standards",
                "50% to less than 60% of students meet growth standards",
                "60% of students or more meet growth standards"), ordered = TRUE)

        data.frame(elpa_growth) %>%
            rhandsontable(rowHeaderWidth = 225, rowHeaders = subgroups,
                colHeaders = c("Percent of Students Meeting Differentiated Growth Standard")) %>%
            hot_context_menu(allowColEdit = FALSE, allowRowEdit = FALSE) %>%
            hot_rows(rowHeights = 40) %>%
            hot_col(c("Percent of Students Meeting Differentiated Growth Standard"), type = "dropdown")

    })

    # Inputs for absenteeism
    output$absenteeism_table <- renderRHandsontable({

        absenteeism_abs <- factor(c("Percent of chronically absent students is greater than 9 percent and less than or equal to 13 percent", rep("N/A", 5)),
            levels = c("N/A",
                "Percent of chronically absent students is greater than 20 percent",
                "Percent of chronically absent students is greater than 13 percent and less than or equal to 20 percent",
                "Percent of chronically absent students is greater than 9 percent and less than or equal to 13 percent",
                "Percent of chronically absent students is greater than 6 percent and less than or equal to 9 percent",
                "Percent of chronically absent students is less than or equal to 6 percent"), ordered = TRUE)

        absenteeism_target <- factor(c("Lower bound of Chronic Absence rate confidence interval is less than or equal to AMO target", rep("N/A", 5)),
            levels = c("N/A",
                "Lower bound of Chronic Absence rate confidence interval equals or exceeds prior year Chronic Absence rate",
                "Lower bound of Chronic Absence rate confidence interval is less than prior Chronic Absence rate",
                "Lower bound of Chronic Absence rate confidence interval is less than or equal to AMO target",
                "Chronic Absence rate is less than AMO target",
                "Chronic Absence rate is less than or equal to double AMO target"), ordered = TRUE)

        data.frame(absenteeism_abs, absenteeism_target) %>%
            rhandsontable(rowHeaderWidth = 225, rowHeaders = subgroups,
                colHeaders = c("Absenteeism", "Absenteeism Reduction Target")) %>%
            hot_context_menu(allowColEdit = FALSE, allowRowEdit = FALSE) %>%
            hot_cols(colWidths = c(350, 350)) %>%
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
            # inner_join(grad(), by = "Subgroup") %>%
            inner_join(readiness(), by = "Subgroup") %>%
            inner_join(elpa(), by = "Subgroup") %>%
            inner_join(absenteeism(), by = "Subgroup") %>%
            mutate_at(c("success_rate", "success_target", "TVAAS", "subgroup_growth",
                "grad_abs", "grad_target", "readiness_abs", "readiness_target",
                "elpa_growth", "absenteeism_abs", "absenteeism_target"),
                funs(if_else(as.numeric(.) == 1, NA_real_, as.numeric(.) - 2))) %>%
        # Not setting na.rm = TRUE so that schools are only evaluated if they have absolute and target grades
            mutate(grade_achievement = pmax(success_rate, success_target),
                grade_growth = if_else(Subgroup == "All Students", TVAAS, subgroup_growth),
                grade_grad = pmax(grad_abs, grad_target),
                grade_readiness = pmax(readiness_abs, readiness_target),
                grade_elpa = elpa_growth,
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
