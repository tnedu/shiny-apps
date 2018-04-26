library(acct)
library(shiny)

ui <- fluidPage(

    h3("What's my CI?"),
    p("Calculate confidence interval lower/upper bounds for accountability."),
    br(),

    textInput("n", label = "How many valid tests?", value = 30),
    sliderInput("pct", label = "What's the percentage on track/mastered?", width = '500px',
        min = 0, max = 100, value = 50, step = 0.1),
    br(),
    br(),

    h4(textOutput("lower")),
    h4(textOutput("upper"))
)

server <- function(input, output, session){
    output$lower <- renderText(

        paste("Your CI lower bound is",
            ci_lower_bound(n = as.integer(input$n), pct = input$pct))

    )

    output$upper <- renderText({

        paste("Your CI upper bound is",
            ci_upper_bound(n = as.integer(input$n), pct = input$pct))

    })
}

shinyApp(ui = ui, server = server)
