library(shiny)
library(ggplot2)
library(dplyr)
library(markdown)
library(mgcv)
library(psych)

navbarPage(
    title = "Vancomycin TDM KR",
    tabPanel(
        title = "Single",
        sidebarLayout(
            sidebarPanel(
                sliderInput(
                    inputId = "concCCR",  
                    label = "CCR", 
                    min = 1, max = 150, value = 100, step = 1),
                #helpText('help'),
                
                sliderInput('concDose', 'Vancomycin Dose (mg)', min=0, max=2000,
                            value=1000, step=5),
                sliderInput('concNum', 'Simulations N', min=5, max=2000,
                            value=20, step=5),
                checkboxInput(inputId = "Log", label = "Log scale")
            ),
            
            mainPanel(
                tags$h3("Concentration-time Curves of Vancomycin"),
                plotOutput("concplot"),
                includeMarkdown("reference.md"),
                tags$h3("Descriptive Statistics of PK parameters"),
                tableOutput("conccontents"),
                tags$h3("Individual PK parameters"),
                dataTableOutput("showdata"),
                checkboxInput(inputId = "showme", label = "Show me all the data entries together."),
                tableOutput("showdataall")
            )
        )
    ),
    
    tabPanel(
        title = "Help", 
        withMathJax(includeMarkdown("README.md"))
    ),
    
    tabPanel(
        title = "Contact", 
        includeMarkdown("CONTACT.md"),
        includeHTML("disqus.html"),
        includeMarkdown("app.md")
    )
)