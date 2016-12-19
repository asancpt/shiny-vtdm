library(shiny)
library(ggplot2)
library(dplyr)
library(markdown)
library(mgcv)
library(psych)

CaffSigma <- matrix(c(0.120, 0, 0, 
                      0, 0.149, 0, 
                      0, 0, 0.416), nrow = 3)
CaffMu <- c(0,0,0)
Seed <- sample.int(10000, size = 1)

round_df <- function(x, digits) {
    # round all numeric variables
    # x: data frame 
    # digits: number of digits to round
    numeric_columns <- sapply(x, mode) == 'numeric'
    x[numeric_columns] <-  round(x[numeric_columns], digits)
    x
}

Dataset <- function(CrCL, Dose, Num){
    set.seed(Seed)
    MVN <- rmvn(Num, CaffMu, CaffSigma);  
    MVNdata <- data.frame(MVN, stringsAsFactors = FALSE) %>% 
        select(eta1 = X1, eta2 = X2, eta3 = X3) %>% 
        mutate(V1 = 33.1 * exp(eta1), 
               V2 = 48.3,
               CL = 3.96 * CrCL / 100 * exp(eta2),
               Q = 6.99 * exp(eta3),
               k10 = CL / V1,
               k12 = Q / V1,
               k21 = Q / V2,
               lam1 = (k10 + k12 + k21 + sqrt((k10+k12+k21)^2 - 4*k10*k21))/2,
               lam2 = k10 + k12 + k21 - lam1,
               Conc1 = (lam1 - k21)/(V1 *(lam1 - lam2)),
               Conc2 = (k21 - lam2)/(V1 *(lam1 - lam2)))
    return(MVNdata)
}

Describe <- function(df){
    DescribeMVNRaw <- describe(df, quant = c(.25, .75)) 
    DescribeMVNRaw[, "Parameters"] <- row.names(DescribeMVNRaw)
    DescribeMVN <- DescribeMVNRaw %>% select(Parameters, median, sd, min, Q0.25, mean, Q0.75, max)
    return(DescribeMVN)
}

Calculate <- function(df, DOSE, NUM, DUR, END = 12){
    Subject <- seq(1, NUM, length.out = NUM) # 
    Time <- seq(0, END, by = 0.25)
    Grid <- expand.grid(x = Subject, y = Time) %>% select(Subject=x, Time=y)
    Rate <- DOSE / DUR
    Calcconc <- df %>% 
        mutate(Subject = row_number()) %>% 
        left_join(Grid, by = "Subject") %>% 
        mutate(Conc = ifelse(
            Time < DUR,
            Rate/lam1 * Conc1 * (1 - exp(-1 * lam1 * Time)) + 
                Rate/lam2 * Conc2 * (1 - exp(-1 * lam2 * Time)),
            Rate/lam1 * Conc1 * (1 - exp(-1 * lam1 * DUR)) * 
                exp(-1 * lam1 * (Time-DUR)) + 
                Rate/lam2 * Conc2 * (1 - exp(-1 * lam2 * DUR)) * 
                exp(-1 * lam2 * (Time - DUR))))
    return(Calcconc)
}

shinyServer(function(input, output, session) {
    output$conccontents <- renderTable({
        CCR <- (140 - input$concAge) * input$concWeight * as.numeric(input$concSex)/ (72 * input$concCr)
        #return(CCR)
        Describe(Dataset(CCR, input$concDose, input$concNum) %>% 
                     select(-eta1, -eta2, -eta3, -lam1, -lam2, -Conc1, -Conc2))
    })
    
    output$showdata <- renderDataTable({
        CCR <- (140 - input$concAge) * input$concWeight * as.numeric(input$concSex) / (72 * input$concCr)
        ### Start ###
        showdataTable <- round_df(Dataset(CCR, input$concDose, input$concNum), 2) %>% 
            mutate(SUBJID = row_number()) %>% 
            select(SUBJID, V1:k21, -lam1, -lam2, -Conc1, -Conc2) 
        return(showdataTable)
    }, options = list(pageLength = 10))
    
    output$showdataall <- renderTable({
        ### Start ###
        if (input$showme == FALSE)
            return(NULL)
        CCR <- (140 - input$concAge) * input$concWeight * as.numeric(input$concSex) / (72 * input$concCr)
        showall <- Dataset(CCR, input$concDose, input$concNum) %>% 
            mutate(SUBJID = as.character(row_number())) %>% 
            select(SUBJID, V1:k21, eta1:eta3, -lam1, -lam2, -Conc1, -Conc2) 
        return(showall)
    })
    
    output$supercontents <- renderTable({
        CCR <- (140 - input$superAge) * input$superWeight * as.numeric(input$superSex)/ (72 * input$superCr)
        #return(CCR)
        Describe(Dataset(CCR, input$superDose, input$superNum) %>% 
                     select(-eta1, -eta2, -eta3, -lam1, -lam2, -Conc1, -Conc2))
    })
    
    output$supershowdata <- renderDataTable({
        CCR <- (140 - input$superAge) * input$superWeight * as.numeric(input$superSex) / (72 * input$superCr)
        ### Start ###
        showdataTable <- round_df(Dataset(CCR, input$superDose, input$superNum), 2) %>% 
            mutate(SUBJID = row_number()) %>% 
            select(SUBJID, V1:k21, -lam1, -lam2, -Conc1, -Conc2) 
        return(showdataTable)
    }, options = list(pageLength = 10))
    
    output$supershowdataall <- renderTable({
        ### Start ###
        if (input$supershowme == FALSE)
            return(NULL)
        CCR <- (140 - input$superAge) * input$superWeight * as.numeric(input$superSex) / (72 * input$superCr)
        showall <- Dataset(CCR, input$superDose, input$superNum) %>% 
            mutate(SUBJID = as.character(row_number())) %>% 
            select(SUBJID, V1:k21, eta1:eta3, -lam1, -lam2, -Conc1, -Conc2) 
        return(showall)
    })
    
    output$concplot <- renderPlot({
        CCR <- (140 - input$concAge) * input$concWeight * as.numeric(input$concSex) / (72 * input$concCr)
        ggConc <- Dataset(CCR, input$concDose, input$concNum) %>% 
            Calculate(DOSE = input$concDose, NUM = input$concNum, DUR = input$concDUR)
        
        concRed <- as.numeric(input$concrange[2])
        concGreen <- as.numeric(input$concrange[1])
        
        p <- ggplot(ggConc, aes(x=Time, y=Conc)) + theme_linedraw() +
            labs(x = "Time (hour)", y = "Concentration (mg/L)",
                 title = paste0("Single Dosing of Vancomycin ", 
                           input$concDose, " mg IV Infusion for ", input$concDUR, 
                           "hr \nto ", ifelse(input$concSex == "1", "Male", "Female")," Patients with CrCl=", round(CCR,0), " (N = ", input$concNum, ")")) +
            theme(plot.title = element_text(size = rel(1.6))) +
            scale_x_continuous(breaks = seq(from = 0, to = 24, by = 4)) +
            geom_line(aes(group = Subject, colour = Conc)) + 
            stat_summary(fun.y = "mean", colour = "#F0E442", size = 1, geom = "line") +
            geom_hline(yintercept = concRed, colour="red") + 
            geom_hline(yintercept = concGreen, colour="green")
        
        if (input$concLog == FALSE) print(p) else 
            print(p + scale_y_log10()) #limits = c(0.1, max(80, ggsuper$Conc))))
    })
    
    output$superplot <- renderPlot({
        superCCR <- (140 - input$superAge) * input$superWeight * as.numeric(input$superSex) / (72 * input$superCr)
        ggConc <- Dataset(superCCR, input$superDose, input$superNum) %>% 
            Calculate(DOSE = input$superDose, NUM = input$superNum, DUR = input$superDUR, END = 168)
        
        ggsuper <- ggConc %>% 
            group_by(Subject) %>% 
            mutate(ConcOrig = Conc, 
                   ConcTemp = 0)
        ## Superposition
        for (i in 1:input$superRepeat){
            Frame <- input$superTau * 4 * i
            ggsuper <- ggsuper %>% 
                mutate(Conc = Conc + ConcTemp) %>% 
                mutate(ConcTemp = lag(ConcOrig, n = Frame, default = 0))
        }
        superRed <- as.numeric(input$superrange[2])
        superGreen <- as.numeric(input$superrange[1])
        p <- ggplot(ggsuper, aes(x=Time, y=Conc)) + theme_linedraw() +
            labs(x = "Time (hour)", y = "Concentration (mg/L)",
                 title = paste0("Multiple Dosing of Vancomycin ", 
                           input$superDose, " mg IV Infusion for ", input$superDUR, 
                           "hr \nto ", ifelse(input$superSex == "1", "Male", "Female")," Patients with CrCl=", round(superCCR,0), " every ", input$superTau, 
                           "hr (N = ", input$superNum, ")")) +
            theme(plot.title = element_text(size = rel(1.6))) +
            scale_x_continuous(breaks = seq(0, 192, 12)) +
            geom_line(aes(group = Subject, colour = Conc)) +
            stat_summary(fun.y = "mean", colour = "#F0E442", size = 1, geom = "line") +
            geom_hline(yintercept = superRed, colour="red") + 
            geom_hline(yintercept = superGreen, colour="green")
        
        if (input$superLog == FALSE) print(p) else print(p + scale_y_log10())#limits = c(0.1, max(80, ggsuper$Conc))))
    })
})
