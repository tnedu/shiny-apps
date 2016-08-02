## Data Explorer - Motion Chart
# server.R

shinyServer(function(input, output) {

    output$chart <- renderGvis({
        gvisMotionChart(ach_profile, idvar = "District", timevar = "Year",
            xvar = "Percent Economically Disadvantaged", yvar = "Math Percent Proficient or Advanced",
            sizevar = "Student Enrollment", colorvar = "CORE Region",
            options = list(width = 1000, height = 800))
    })

    }
)
