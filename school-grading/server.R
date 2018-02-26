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
        if (input$success_3yr %in% c("Less than 10%", "Between 10% and 15%")) {
            show("tvaas_lag", anim = TRUE)

            if (input$tvaas_lag == "") {
                hide("button_priority", anim = TRUE)
            } else {
                show("button_priority", anim = TRUE)
            }

        } else if (input$success_3yr == "Above 15%") {
            show("button_priority", anim = TRUE)
            hide("tvaas_lag", anim = TRUE)
        }
    })

    observeEvent(input$button_priority, once = TRUE, {
        hide("minimum_performance", anim = TRUE)
        show("tabs_panel", anim = TRUE)
    })

    observeEvent(input$button_ach, once = TRUE, {

        hide("done_ach", anim = TRUE)

        appendTab(inputId = "tabs", select = TRUE,
            tabPanel("Grad",
                h4("About your school's 2017 graduation rate"),
                br(),
                selectInput("grad_eligible", label = "Does your school have a 2017 graduating
                    cohort (2013 cohort) of 30 or more students?", choices = c("", "Yes", "No")),
                hidden(div(id = "grad_table_container",
                    p(strong("Graduation rate"), "is the percentage of students in the graduating
                        cohort who graduate in no more than four years plus a summer."),
                    br(),
                    strong(p("Answer the following about your school's 2017 graduation rate.")),
                    rHandsontableOutput("grad_table")
                )),
                hidden(actionButton("skip_grad", label = "Proceed")),
                    br(),
                hidden(div(id = "done_grad",
                    p("When you are done, click the button below."),
                    actionButton("button_grad", label = "Done")
                ))
            )
        )

    })

    observeEvent(input$grad_eligible, {
        if (input$grad_eligible == "Yes") {
            show("grad_table_container", anim = TRUE)
            show("done_grad", anim = TRUE)
            hide("skip_grad", anim = TRUE)
        } else if (input$grad_eligible == "No") {
            hide("grad_table_container", anim = TRUE)
            hide("done_grad", anim = TRUE)
            show("skip_grad", anim = TRUE)
        } else {
            hide("grad_table_container", anim = TRUE)
            hide("done_grad", anim = TRUE)
            hide("skip_grad", anim = TRUE)
        }
    })

    observeEvent(input$skip_grad, once = TRUE, {

        hide("grad", anim = TRUE)
        hide("skip_grad", anim = TRUE)

        appendTab(inputId = "tabs", select = TRUE,
            tabPanel("ELPA",
                h4("About your school's English Language Proficiency Assessment Results"),
                br(),
                selectInput("elpa_eligible", label = "Does your school have 10 or more
                    students who took an English Language Proficiency Assessment (ELPA)?",
                    choices = c("", "Yes", "No")),
                hidden(div(id = "elpa_table_container",
                    p("Schools are graded on the percentage of students who meet the",
                        strong("growth standard"), "on the English Language Proficiency Assessment."),
                    br(),
                    strong(p("Answer the following about your school's ELPA growth.")),
                    rHandsontableOutput("elpa_table")
                )),
                hidden(actionButton("skip_elpa", label = "Proceed")),
                br(),
                hidden(div(id = "done_elpa",
                    p("When you are done, click the button below."),
                    actionButton("button_elpa", label = "Done")
                ))
            )
        )

    })

    observeEvent(input$button_grad, once = TRUE, {

        hide("grad_eligible", anim = TRUE)
        hide("done_grad", anim = TRUE)

        appendTab(inputId = "tabs", select = TRUE,
            tabPanel("Ready Graduates",
                h4("About your school's 2017 ready graduates"),
                br(),
                p(strong("Ready graduates"), "refers to 2017 graduates who earned
                    an ACT composite score of 21 or higher."),
                br(),
                strong(p("Answer the following about your school's ready graduates.")),
                rHandsontableOutput("ready_grad_table"),
                br(),
                div(id = "done_ready_grad",
                    p("When you are done, click the button below."),
                    actionButton("button_ready_grad", label = "Done")
                )
            )
        )

    })

    observeEvent(input$button_ready_grad, once = TRUE, {

        hide("done_ready_grad", anim = TRUE)

        if (input$skip_grad == 0) {
            appendTab(inputId = "tabs", select = TRUE,
                tabPanel("ELPA",
                    h4("About your school's English Language Proficiency Assessment Results"),
                    br(),
                    selectInput("elpa_eligible", label = "Does your school have 10 or more
                        students who took an English Language Proficiency Assessment (ELPA)?",
                        choices = c("", "Yes", "No")),
                    hidden(div(id = "elpa_table_container",
                        p("Schools are graded on the percentage of students who meet the",
                            strong("growth standard"), "on the English Language Proficiency Assessment."),
                        br(),
                        strong(p("Answer the following about your school's ELPA growth.")),
                        rHandsontableOutput("elpa_table")
                    )),
                    hidden(actionButton("skip_elpa", label = "Proceed")),
                    br(),
                    hidden(div(id = "done_elpa",
                        p("When you are done, click the button below."),
                        actionButton("button_elpa", label = "Done")
                    ))
                )
            )
        }

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

        hide("elpa_eligible", anim = TRUE)
        hide("done_elpa", anim = TRUE)

        if (input$skip_elpa == 0) {
            appendTab(inputId = "tabs", select = TRUE,
                tabPanel("Absenteeism",
                    h4("About your school's chronic absenteeism"),
                    br(),
                    p(strong("Chronic absenteeism"), "refers to students who are absent for 10%
                        or more of a school year (e.g., 18 days in a 180 day school year).
                        Chronic absenteeism calculations only include students who are enrolled
                        for at least 50 percent of the school year."),
                    br(),
                    strong(p("Answer the following about your school's chronic absenteeism.")),
                    rHandsontableOutput("absenteeism_table"),
                    br(),
                    div(id = "done_absenteeism",
                        p("When you are done, click the button below."),
                        actionButton("button_absenteeism", label = "Done")
                    )
                )
            )
        }

    })

    observeEvent(input$skip_elpa, once = TRUE, {

        hide("elpa", anim = TRUE)
        hide("skip_elpa", anim = TRUE)

        show("done_absenteeism", anim = TRUE)
        appendTab(inputId = "tabs", select = TRUE,
            tabPanel("Absenteeism",
                h4("About your school's chronic absenteeism"),
                br(),
                p(strong("Chronic absenteeism"), "refers to students who are absent for 10%
                    or more of a school year (e.g., 18 days in a 180 day school year).
                    Chronic absenteeism calculations only include students who are enrolled
                    for at least 50 percent of the school year."),
                br(),
                strong(p("Answer the following about your school's chronic absenteeism.")),
                rHandsontableOutput("absenteeism_table"),
                br(),
                div(id = "done_absenteeism",
                    p("When you are done, click the button below."),
                    actionButton("button_absenteeism", label = "Done")
                )
            )
        )

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
            "Less than 10%" = switch(input$tvaas_lag,
                "No" = "<p>Your school is <b>at risk of being named a Priority (F) School</b>.</p>
                    <p>To avoid being named a Priority School, your school must perform
                    <b>above the bottom 5 percent of schools based on a three year success rate</b>
                    in 2018.</p>",
                    "Yes" = "<p>Your school is <b>at risk of being named a Priority (F) School</b>.</p>
                    <p>To avoid being named a Priority School, your school must perform
                    <b>above the bottom 5 percent of schools based on a three year success rate</b>
                    OR <b>earn a TVAAS Composite Level 4 or 5</b> in 2018.</p>"),
               "Between 10% and 15%" = switch(input$tvaas_lag,
                    "No" = "<p>Your school is <b>on the cusp of being a Priority (F) School</b>.</p>
                    <p>To avoid being named a Priority school, your school must perform
                    <b>above the bottom 5 percent of schools based on a three year success rate</b>
                    in 2018.<p>",
                    "Yes" = "<p>Your school is <b>on the cusp of being a Priority (F) School</b>.</p>
                    <p>To avoid being named a Priority school, your school must perform
                    <b>above the bottom 5 percent of schools based on a three year success rate</b>
                    OR <b>earn a Level 4 or 5 Composite TVAAS</b> in 2018.</p>"),
               "Above 15%" = "<p>Your school is <b>unlikely to be named a Priority (F) School</b>.</p>"
        )
    )

    # Inputs for achievement/growth
    output$achievement_table <- renderRHandsontable({

        success_rate <- factor(c("One-year success rate is greater than or equal to 35% but less than 45%",
                rep("N/A - School does not serve 30 students in this subgroup", 5)),
            levels = c("N/A - School does not serve 30 students in this subgroup",
                "One-year success rate is less than 25%",
                "One-year success rate is greater than or equal to 25% but less than 35%",
                "One-year success rate is greater than or equal to 35% but less than 45%",
                "One-year success rate is greater than or equal to 45% and less than 50%",
                "One-year success rate is greater or equal to 50%"), ordered = TRUE)

        success_target <- factor(c("Upper bound of one-year success rate confidence interval equals or exceeds AMO target",
                rep("N/A - School does not serve 30 students in this subgroup", 5)),
            levels = c("N/A - School does not serve 30 students in this subgroup",
                "Upper bound of one-year success rate confidence interval is less than or equal to prior one-year success rate",
                "Upper bound of one-year success rate confidence interval exceeds prior one-year success rate",
                "Upper bound of one-year success rate confidence interval equals or exceeds AMO target",
                "One-year success rate exceeds AMO target",
                "One-year success rate exceeds double AMO target"), ordered = TRUE)

        TVAAS <- factor(c("Level 3", rep("N/A", 5)), ordered = TRUE,
            levels = c("N/A", "Level 1", "Level 2", "Level 3", "Level 4", "Level 5"))

        data.frame(success_rate, success_target, TVAAS) %>%
            rhandsontable(rowHeaderWidth = 225, rowHeaders = subgroups,
                colHeaders = c("Success Rate", "Success Rate Target", "TVAAS")) %>%
            hot_context_menu(allowColEdit = FALSE, allowRowEdit = FALSE) %>%
            hot_cols(colWidths = c(250, 300, 150)) %>%
            hot_rows(rowHeights = 40) %>%
            hot_col(c("Success Rate", "Success Rate Target", "TVAAS"), type = "dropdown")

    })

    # Inputs for graduation rate
    output$grad_table <- renderRHandsontable({

        grad_abs <- factor(c("Graduation rate is greater than or equal to 80% but less than 90%",
                rep("N/A - School does not serve 30 students in this subgroup", 5)),
            levels = c("N/A - School does not serve 30 students in this subgroup",
                "Graduation rate is less than 67%",
                "Graduation rate is greater than or equal to 67% but less than 80%",
                "Graduation rate is greater than or equal to 80% but less than 90%",
                "Graduation rate is greater than or equal to 90% but less than 95%",
                "Graduation rate is 95% or greater"), ordered = TRUE)

        grad_target <- factor(c("Upper bound of graduation rate confidence interval equals or exceeds AMO target",
                rep("N/A - School does not serve 30 students in this subgroup", 5)),
            levels = c("N/A - School does not serve 30 students in this subgroup",
                "Upper bound of graduation rate confidence interval is less than or equal to prior year graduation rate",
                "Upper bound of graduation rate confidence interval exceeds prior graduation rate",
                "Upper bound of graduation rate confidence interval equals or exceeds AMO target",
                "Graduation rate exceeds AMO target",
                "Graduation rate exceeds double AMO target"), ordered = TRUE)

        data.frame(grad_abs, grad_target) %>%
            rhandsontable(rowHeaderWidth = 225, rowHeaders = subgroups,
                colHeaders = c("Graduation Rate", "Graduation Rate Target")) %>%
            hot_context_menu(allowColEdit = FALSE, allowRowEdit = FALSE) %>%
            hot_cols(colWidths = c(350, 350)) %>%
            hot_rows(rowHeights = 40) %>%
            hot_col(c("Graduation Rate", "Graduation Rate Target"), type = "dropdown")

    })

    # Inputs for ACT and grad
    output$ready_grad_table <- renderRHandsontable({

        ready_grad_abs <- factor(c("25% to less than 30% of graduates score a 21+ on the ACT",
                rep("N/A - School does not serve 30 students in this subgroup", 5)),
            levels = c("N/A - School does not serve 30 students in this subgroup",
                "Less than 16% of graduates score a 21+ on the ACT",
                "16% to less than 25% of graduates score a 21+ on the ACT",
                "25% to less than 30% of graduates score a 21+ on the ACT",
                "30% to less than 40% of graduates score a 21+ on the ACT",
                "40% or more of graduates score a 21+ on the ACT"), ordered = TRUE)

        ready_grad_target <- factor(c("Upper bound of ready graduates confidence interval equals or exceeds AMO target",
                rep("N/A - School does not serve 30 students in this subgroup", 5)),
            levels = c("N/A - School does not serve 30 students in this subgroup",
                "Upper bound of ready graduates confidence interval is less than or equal to prior year ready graduates",
                "Upper bound of ready graduates confidence interval exceeds prior year ready graduates",
                "Upper bound of ready graduates confidence interval equals or exceeds AMO target",
                "Ready graduates exceeds AMO target",
                "Ready graduates exceeds double AMO target"), ordered = TRUE)

        data.frame(ready_grad_abs, ready_grad_target) %>%
            rhandsontable(rowHeaderWidth = 225, rowHeaders = subgroups,
                colHeaders = c("Ready Graduates", "Ready Graduates Target")) %>%
            hot_context_menu(allowColEdit = FALSE, allowRowEdit = FALSE) %>%
            hot_cols(colWidths = c(350, 350)) %>%
            hot_rows(rowHeights = 40) %>%
            hot_col(c("Ready Graduates", "Ready Graduates Target"), type = "dropdown")

    })

    # Inputs for ELPA
    output$elpa_table <- renderRHandsontable({

        elpa_growth <- factor(c("40% to less than 50% of students meet growth standards",
                rep("N/A - School does not serve 10 students in this subgroup", 3),
                "40% to less than 50% of students meet growth standards",
                "N/A - School does not serve 10 students in this subgroup"),
            levels = c("N/A - School does not serve 10 students in this subgroup",
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

        absenteeism_abs <- switch(input$grad_eligible,
            "Yes" = factor(c("Chronic Absenteeism is greater than 14% and less than or equal to 20%",
                    rep("N/A - School does not serve 30 students in this subgroup", 5)),
                levels = c("N/A - School does not serve 30 students in this subgroup",
                    "Chronic Absenteeism is greater than 30%",
                    "Chronic Absenteeism is greater than 20% and less than or equal to 30%",
                    "Chronic Absenteeism is greater than 14% and less than or equal to 20%",
                    "Chronic Absenteeism is greater than 10% and less than or equal to 14%",
                    "Chronic Absenteeism is less than or equal to 10%"), ordered = TRUE),
            "No" = factor(c("Chronic Absenteeism is greater than 9% and less than or equal to 13%",
                    rep("N/A - School does not serve 30 students in this subgroup", 5)),
                levels = c("N/A - School does not serve 30 students in this subgroup",
                    "Chronic Absenteeism is greater than 20%",
                    "Chronic Absenteeism is greater than 13% and less than or equal to 20%",
                    "Chronic Absenteeism is greater than 9% and less than or equal to 13%",
                    "Chronic Absenteeism is greater than 6% and less than or equal to 9%",
                    "Chronic Absenteeism is less than or equal to 6%"), ordered = TRUE)
        )

        absenteeism_target <- factor(c("Lower bound of Chronic Absenteeism confidence interval is less than or equal to AMO target",
                rep("N/A - School does not serve 30 students in this subgroup", 5)),
            levels = c("N/A - School does not serve 30 students in this subgroup",
                "Lower bound of Chronic Absenteeism confidence interval equals or exceeds prior year Chronic Absenteeism",
                "Lower bound of Chronic Absenteeism confidence interval is less than prior year Chronic Absenteeism",
                "Lower bound of Chronic Absenteeism confidence interval is less than or equal to AMO target",
                "Chronic Absenteeism is less than AMO target",
                "Chronic Absenteeism is less than or equal to double AMO target"), ordered = TRUE)

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

    grad <- reactive(
        if (is.null(input$grad_table) || input$grad_eligible == "No") {
            data_frame(Subgroup = subgroups,
                grad_abs = factor(rep(NA, 6)),
                grad_target = factor(rep(NA, 6)))
        } else {
            input$grad_table %>%
                hot_to_r() %>%
                as_data_frame() %>%
                mutate(Subgroup = subgroups)
        }
    )

    ready_grad <- reactive(
        if (is.null(input$ready_grad_table) || input$grad_eligible == "No") {
            data_frame(Subgroup = subgroups,
                ready_grad_abs = factor(rep(NA, 6)),
                ready_grad_target = factor(rep(NA, 6)))
        } else {
            input$ready_grad_table %>%
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

        ach() %>%
            inner_join(grad(), by = "Subgroup") %>%
            inner_join(ready_grad(), by = "Subgroup") %>%
            inner_join(elpa(), by = "Subgroup") %>%
            inner_join(absenteeism(), by = "Subgroup") %>%
            mutate_at(c("success_rate", "success_target", "TVAAS",
                    "grad_abs", "grad_target", "ready_grad_abs", "ready_grad_target",
                    "elpa_growth", "absenteeism_abs", "absenteeism_target"),
                funs(if_else(as.numeric(.) == 1, NA_real_, as.numeric(.) - 2))) %>%
        # Not setting na.rm = TRUE so that schools are only evaluated if they have absolute and target grades
            transmute(Subgroup,
                grade_achievement = pmax(success_rate, success_target),
                grade_growth = TVAAS,
                grade_grad = pmax(grad_abs, grad_target),
                grade_ready_grad = pmax(ready_grad_abs, ready_grad_target),
                grade_elpa = elpa_growth,
                grade_absenteeism = pmax(absenteeism_abs, absenteeism_target))

    })

    output$heatmap <- renderTable({

        heat_map() %>%
        # Drop Super Subgroup if other subgroups are present
            mutate(temp = pmax(grade_achievement, grade_growth, grade_grad, grade_ready_grad, grade_elpa, grade_absenteeism, na.rm = TRUE),
                subgroup_count = sum(!is.na(temp), na.rm = TRUE)) %>%
            filter(!(Subgroup == "Super Subgroup" & (subgroup_count > 2 | is.na(temp)))) %>%
            mutate_at(c("grade_achievement", "grade_growth", "grade_grad", "grade_ready_grad", "grade_elpa", "grade_absenteeism"),
                as.numeric) %>%
            mutate_at(c("grade_achievement", "grade_growth", "grade_grad", "grade_ready_grad", "grade_elpa", "grade_absenteeism"),
                funs(recode(.,  "4" = "A", "3" = "B", "2" = "C", "1" = "D", "0" = "F"))) %>%
            transmute(Subgroup,
                `Achievement Grade` = grade_achievement,
                `Growth Grade` = grade_growth,
                `Graduation Rate Grade` = grade_grad,
                `Ready Graduates Grade` = grade_ready_grad,
                `ELPA Grade` = grade_elpa,
                `Absenteeism Grade` = grade_absenteeism)
    })

    final_grades <- reactive({

        subgroup_grades <- heat_map() %>%
            filter(Subgroup %in% c("Black/Hispanic/Native American", "Economically Disadvantaged",
                "Students with Disabilities", "English Learners", "Super Subgroup")) %>%
            mutate(temp = pmax(grade_achievement, grade_growth, grade_grad, grade_ready_grad, grade_elpa, grade_absenteeism, na.rm = TRUE),
                subgroup_count = sum(!is.na(temp), na.rm = TRUE)) %>%
            filter(!(Subgroup == "Super Subgroup" & subgroup_count > 1)) %>%
            summarise_at(c("grade_achievement", "grade_growth", "grade_grad", "grade_ready_grad", "grade_absenteeism", "grade_elpa"),
                mean, na.rm = TRUE) %>%
            rename(grade_achievement_subgroups = grade_achievement,
                grade_growth_subgroups = grade_growth,
                grade_grad_subgroups = grade_grad,
                grade_ready_grad_subgroups = grade_ready_grad,
                grade_absenteeism_subgroups = grade_absenteeism,
                grade_elpa_subgroups = grade_elpa)

        grades <- heat_map() %>%
            filter(Subgroup == "All Students") %>%
            select(grade_achievement_all = grade_achievement,
                grade_growth_all = grade_growth,
                grade_grad_all = grade_grad,
                grade_ready_grad_all = grade_ready_grad,
                grade_absenteeism_all = grade_absenteeism,
                grade_elpa_all = grade_elpa) %>%
            bind_cols(subgroup_grades) %>%
            mutate(grade_achievement = case_when(
                    !is.na(grade_achievement_subgroups) ~ 0.6 * grade_achievement_all + 0.4 * grade_achievement_subgroups,
                    is.na(grade_achievement_subgroups) ~ grade_achievement_all
                ),
                grade_growth = case_when(
                    !is.na(grade_growth_subgroups) ~ 0.6 * grade_growth_all + 0.4 * grade_growth_subgroups,
                    is.na(grade_growth_subgroups) ~ grade_growth_all
                ),
                grade_grad = case_when(
                    !is.na(grade_grad_subgroups) ~ 0.6 * grade_grad_all + 0.4 * grade_grad_subgroups,
                    is.na(grade_grad_subgroups) ~ grade_grad_all
                ),
                grade_ready_grad = case_when(
                    !is.na(grade_ready_grad_subgroups) ~ 0.6 * grade_ready_grad_all + 0.4 * grade_ready_grad_subgroups,
                    is.na(grade_ready_grad_subgroups) ~ grade_ready_grad_all
                ),
                grade_absenteeism = case_when(
                    !is.na(grade_absenteeism_subgroups) ~ 0.6 * grade_absenteeism_all + 0.4 * grade_absenteeism_subgroups,
                    is.na(grade_absenteeism_subgroups) ~ grade_absenteeism_all
                ),
                grade_elpa = case_when(
                    !is.na(grade_elpa_subgroups) ~ 0.6 * grade_elpa_all + 0.4 * grade_elpa_subgroups,
                    is.na(grade_elpa_subgroups) ~ grade_elpa_all
                )
            )

        if (input$grad_eligible == "Yes") {
            weights <- grades %>%
                mutate(weight_achievement = if_else(!is.na(grade_achievement), 0.3, NA_real_),
                    weight_growth = if_else(!is.na(grade_growth), 0.25, NA_real_),
                    weight_grad = if_else(!is.na(grade_grad), 0.05, NA_real_),
                    weight_ready_grad = if_else(!is.na(grade_ready_grad), 0.2, NA_real_),
                    weight_absenteeism = if_else(!is.na(grade_absenteeism), 0.1, NA_real_),
                    weight_elpa = if_else(!is.na(grade_elpa), 0.1, NA_real_),
                # If no ELPA, adjust achievement and growth weights accordingly
                    weight_achievement = if_else(is.na(grade_elpa) & !is.na(grade_achievement), 0.35, weight_achievement),
                    weight_growth = if_else(is.na(grade_elpa) & !is.na(grade_growth), 0.3, weight_growth))
        } else if (input$grad_eligible == "No") {
            weights <- grades %>%
                mutate(weight_achievement = if_else(!is.na(grade_achievement), 0.45, NA_real_),
                    weight_growth = if_else(!is.na(grade_growth), 0.35, NA_real_),
                    weight_grad = NA_real_,
                    weight_ready_grad = NA_real_,
                    weight_absenteeism = if_else(!is.na(grade_absenteeism), 0.1, NA_real_),
                    weight_elpa = if_else(!is.na(grade_elpa), 0.1, NA_real_),
                # If no ELPA, adjust achievement and growth weights accordingly
                    weight_achievement = if_else(is.na(grade_elpa) & !is.na(grade_achievement), 0.5, weight_achievement),
                    weight_growth = if_else(is.na(grade_elpa) & !is.na(grade_growth), 0.4, weight_growth))
        }

        weights %>%
            rowwise() %>%
            mutate(total_weight = sum(weight_achievement, weight_growth, weight_absenteeism,
                    weight_grad, weight_ready_grad, weight_elpa, na.rm = TRUE),
                final_average = round(sum(weight_achievement * grade_achievement,
                    weight_growth * grade_growth,
                    weight_absenteeism * grade_absenteeism,
                    weight_grad * grade_grad,
                    weight_ready_grad * grade_ready_grad,
                    weight_elpa * grade_elpa, na.rm = TRUE)/total_weight, 1)
            )

    })

    output$final_grades <- renderTable(width = "100%",
        final_grades() %>%
            transmute(`Achievement` = grade_achievement,
                `Growth` = grade_growth,
                `Graduation Rate` = grade_grad,
                `Ready Graduate` = grade_ready_grad,
                `Absenteeism` = grade_absenteeism,
                `ELPA` = grade_elpa,
                `Final Grade` = final_average) %>%
            mutate_all(funs(case_when(
                    . > 3 ~ "A",
                    . > 2 ~ "B",
                    . > 1 ~ "C",
                    . >= 0 ~ "D"
                ))
            )
    )

    # output$focus_warning <- renderText({
    #
    #     subgroup_below_one <- heat_map() %>%
    #         filter(Subgroup %in% c("Black/Hispanic/Native American", "Economically Disadvantaged",
    #                 "Students with Disabilities", "English Learners"),
    #             subgroup_average < 1)
    #
    #     if (final_grades()[2, ]$Final == "D") {
    #         "Based on your school's projected D grade, your school is at risk of being
    #         named a focus school."
    #     } else if (nrow(subgroup_below_one) == 0) {
    #         return()
    #     } else if (nrow(subgroup_below_one) == 1) {
    #         paste0("In addition, your school is at risk of being named a Focus School
    #             for the following subgroup: ", c(subgroup_below_one$Subgroup),
    #             ". This means your school would receive a minus on its overall grade,
    #             unless its grade is D or F.")
    #     } else if (nrow(subgroup_below_one) > 1) {
    #         paste0("In addition, your school is at risk of being named a Focus School
    #             for the following subgroups: ", paste(subgroup_below_one$Subgroup, collapse = ", "),
    #             ". This means your school would receive a minus on its overall grade,
    #             unless its grade is D or F.")
    #     }
    #
    # })

    # output$priority_grad_warning <- renderText(
    #     if (is.na(heat_map()[1, ]$grad_abs || heat_map()[1, ]$grad_abs != 0)) {
    #         return()
    #     } else if (heat_map()[1, ]$grad_abs == 0) {
    #         "Your school is at risk of being named a Priority (F) School for
    #         having a graduation rate below 67%."
    #     }
    # )

    output$download_presentation <- downloadHandler(
        filename = "school_grading_user_guide.pdf",
        content = function(file) {
            file.copy("school_grading_user_guide.pdf", file)
        }
    )

    # output$download_data <- downloadHandler(
    #     filename = "school_grading.xlsx",
    #     content = function(file) {
    #
    #         letter_grades <- heat_map() %>%
    #             mutate_at(c("grade_achievement", "grade_growth", "grade_grad", "grade_ready_grad", "grade_absenteeism", "grade_elpa",
    #                 "success_rate", "success_target", "TVAAS", "grad_abs", "grad_target",
    #                 "ready_grad_abs", "ready_grad_target", "elpa_growth", "absenteeism_abs", "absenteeism_target"),
    #                 as.numeric) %>%
    #             mutate_at(c("grade_achievement", "grade_growth", "grade_grad", "grade_ready_grad", "grade_absenteeism", "grade_elpa",
    #                 "success_rate", "success_target", "TVAAS", "grad_abs", "grad_target",
    #                 "ready_grad_abs", "ready_grad_target", "elpa_growth", "absenteeism_abs", "absenteeism_target"),
    #                 funs(recode(.,  "4" = "A", "3" = "B", "2" = "C", "1" = "D", "0" = "F")))
    #
    #         write_xlsx(path = file,
    #             x = list(
    #                 "Heat Map" = letter_grades %>%
    #                     select(Subgroup,
    #                         `Achievement Grade` = grade_achievement,
    #                         `Growth Grade` = grade_growth,
    #                         `Graduation Rate Grade` = grade_grad,
    #                         `Ready Graduates Grade` = grade_ready_grad,
    #                         `ELPA Grade` = grade_elpa,
    #                         `Absenteeism Grade` = grade_absenteeism),
    #                 "Achievement" = letter_grades %>%
    #                     select(Subgroup,
    #                         `Success Rate` = success_rate,
    #                         `Success Rate Target` = success_target,
    #                         `TVAAS` = TVAAS),
    #                 "Graduation" = letter_grades %>%
    #                     select(Subgroup,
    #                         `Graduation Rate` = grad_abs,
    #                         `Graduation Rate Target` = grad_target,
    #                         `Ready Graduates` = ready_grad_abs,
    #                         `Ready Graduates Target` = ready_grad_target),
    #                 "ELPA" = letter_grades %>%
    #                     select(Subgroup,
    #                         `ELPA Growth Standard` = elpa_growth),
    #                 "Absenteeism" = letter_grades %>%
    #                     select(Subgroup,
    #                         `Chronic Absenteeism` = absenteeism_abs,
    #                         `Chronic Absenteeism Reduction Target` = absenteeism_target)
    #             )
    #         )
    #     }
    #
    # )

}
