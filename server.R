library(shiny)
library(ggplot2)
library(dplyr)
library(markdown)
library(mgcv)
library(psych)
library(ggforce)

CaffSigma <- matrix(c(0.120, 0, 0, 
                      0, 0.149, 0, 
                      0, 0, 0.416), nrow = 3)
CaffMu <- c(0,0,0)
Seed <- sample.int(10000, size = 1)
#set.seed(20140523+1)
#BWT = 25; Dose = 80

round_df <- function(x, digits) {
    # round all numeric variables
    # x: data frame 
    # digits: number of digits to round
    numeric_columns <- sapply(x, mode) == 'numeric'
    x[numeric_columns] <-  round(x[numeric_columns], digits)
    x
}

Dataset <- function(CCR, Dose, Num){
  #set.seed(20140523+1)
  MVN <- rmvn(Num, CaffMu, CaffSigma);  
  MVNdata <- data.frame(MVN, stringsAsFactors = FALSE) %>% 
    select(eta1 = X1, eta2 = X2, eta3 = X3) %>% 
    mutate(V1 = 33.1 * exp(eta1), 
           V2 = 48.3,
           CL = 3.96 * CCR / 100 * exp(eta2),
           Q = 6.99 * exp(eta3),
           k10 = CL / V1,
           k12 = Q / V1,
           k21 = Q / V2,
           AUC = Dose / CL,
           lam1 = (k10 + k12 + k21 + sqrt((k10+k12+k21)^2 - 4*k10*k21))/2,
           lam2 = k10 + k12 + k21 - lam1,
           Conc1 = (lam1 - k21)/(V1 *(lam1 - lam2)),
           Conc2 = (k21 - lam2)/(V1 *(lam1 - lam2)))
    return(MVNdata)
}
# Conc = Dose * (Conc1 * exp(-1 * lam1 * Time) + (Conc2 * exp(-1 * lam2 * Time)))


Simul <- function(df){
  MVNSimulRaw <- describe(df, quant = c(.25, .75)) 
  MVNSimulRaw[, "Parameters"] <- row.names(MVNSimulRaw)
  MVNSimul <- MVNSimulRaw %>% select(Parameters, median, sd, min, Q0.25, mean, Q0.75, max)
  return(MVNSimul)
}

shinyServer(function(input, output, session) {
    output$showdata <- renderDataTable({
        ### Start ###
        
        set.seed(Seed)
        #showdataTable <- round_df(Dataset(input$concCCR, input$concDose, input$concNum), 2) %>% 
        showdataTable <- Dataset(input$concCCR, input$concDose, input$concNum) %>% 
            mutate(SUBJID = row_number()) %>% 
            select(9, 1:8)
        return(showdataTable)
    }, options = list(pageLength = 10))
    
    output$showdataall <- renderTable({
        ### Start ###
        
        if (input$showme == FALSE)
            return(NULL)
        
        set.seed(Seed)
        showall <- Dataset(input$concCCR, input$concDose, input$concNum) %>% 
            mutate(SUBJID = as.character(row_number()))
        return(showall)
    })
    
    output$concplot <- renderPlot({
        Subject <- seq(1, input$concNum, length.out = input$concNum) # 
        Time <- seq(0,24, by = 0.1)
        Grid <- expand.grid(x = Subject, y = Time) %>% select(Subject=x, Time=y)
        
        set.seed(Seed)
        ggConc <- Dataset(input$concCCR, input$concDose, input$concNum) %>% 
            mutate(Subject = row_number()) %>% 
            left_join(Grid, by = "Subject") %>% 
            mutate(Conc = input$concDose * (Conc1 * exp(-1 * lam1 * Time) + (Conc2 * exp(-1 * lam2 * Time))))

        p <- ggplot(ggConc, aes(x=Time, y=Conc, group = Subject, colour = Conc)) + 
            xlab("Time (hour)") + ylab("Concentration (mg/L)") +
            scale_x_continuous(breaks = seq(from = 0, to = 24, by = 4)) +
            geom_line()
        
        print(p)
    })
    
    output$conccontents <- renderTable({
        ### Start ###
        Subject <- seq(1, input$concNum, length.out = input$concNum) # 
        Time <- seq(0,24, by = 1)
        Grid <- expand.grid(x = Subject, y = Time) %>% select(Subject=x, Time=y)
        
        set.seed(Seed)
        ggConc <- Dataset(input$concCCR, input$concDose, input$concNum) %>% 
            mutate(Subject = row_number()) %>% 
            left_join(Grid, by = "Subject") %>% 
            mutate(Conc = input$concDose * (Conc1 * exp(-1 * lam1 * Time) + (Conc2 * exp(-1 * lam2 * Time))))
        return(ggConc)
    })
})
