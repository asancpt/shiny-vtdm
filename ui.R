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
            sidebarPanel( # CCR = (140 - input$concAge) * input$concWeight * input$concSex / (72 * input$concCr)
                h4("Dosing Information"),
                sliderInput('concDose', 'Vancomycin Dose (mg)', min=0, max=2000, value=1000, step=50),
                sliderInput('concDUR', 'Infusion Time (hr)', min=0.5, max=10, value=2, step=0.5),
                h4("Patient Information"),
                sliderInput('concCr', label = 'Plasma creatinine (mg/dL)', min = 0, max = 10, value = 1, step = 0.1),
                sliderInput('concAge', 'Age (year)', min=1, max=100, value=30, step=0.5),
                sliderInput('concWeight', label = 'Weight (kg)', min = 0, max = 150, value = 70, step = 0.5),
                radioButtons(
                    inputId = "concSex", label = "Sex",
                    choices = c("Male" = 1, 
                                "Female" = 0.85),
                    selected = 1)
            ),
                #helpText('help'),
            
            mainPanel(
                tags$h3("Concentration-time Curves of Vancomycin"),
                plotOutput("concplot"),
                fluidRow(
                    column(6, 
                           sliderInput("concrange", "Set therapeutic range (mg/L)", 
                                       min = 0, max = 100, c(10, 50)),
                           checkboxInput(inputId = "concLog", label = "Log scale")
                    ),
                    column(6, 
                           sliderInput('concNum', 'Simulations N', min=5, max=2000, value=20, step=5)
                    )
                ),
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
        title = "Multi",
        sidebarLayout(
            sidebarPanel(
                h4("Dosing Information"),
                sliderInput('superDose', 'Vancomycin Dose (mg)', min=0, max=2000, value=1000, step=50),
                sliderInput('superDUR', 'Infusion Time (hr)', min=0.5, max=10, value=2, step=0.5),
                sliderInput('superTau', 'Interval (hr)', min=0, max=48,
                            value=12, step=1),
                sliderInput('superRepeat', 'Repeat (times)', min=1, max=24,
                            value=10, step=1),
                h4("Patient Information"),
                sliderInput('superCr', label = 'Plasma creatinine (mg/dL)', min = 0, max = 10, value = 1.0, step = 0.1),
                sliderInput('superAge', 'Age (year)', min=1, max=100, value=30, step=0.5),
                sliderInput('superWeight', label = 'Weight (kg)', min = 0, max = 150, value = 70, step = 0.5),
                radioButtons(
                    inputId = "superSex", label = "Sex",
                    choices = c("Male" = 1, 
                                "Female" = 0.85),
                    selected = 1)
            ),
            #helpText('help'),
            
            mainPanel(
                tags$h3("Concentration-time Curves of Vancomycin"),
                plotOutput("superplot"),
                fluidRow(
                    column(6, 
                           sliderInput("superrange", "Set therapeutic range (mg/L)", 
                                          min = 0, max = 100, c(10, 50)),
                           checkboxInput(inputId = "superLog", label = "Log scale")
                    ),
                    column(6, 
                           sliderInput('superNum', 'Simulations N', min=5, max=2000, value=20, step=5)
                    )
                ),
                includeMarkdown("reference.md"),
                tags$h3("Descriptive Statistics of PK parameters"),
                tableOutput("supercontents"),
                tags$h3("Individual PK parameters"),
                dataTableOutput("supershowdata"),
                checkboxInput(inputId = "supershowme", label = "Show me all the data entries together."),
                tableOutput("supershowdataall")
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