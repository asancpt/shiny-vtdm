## Vancomycin TDM Kor

- `Vancomycin TDM KR` <https://asan.shinyapps.io/vtdm>
- `Vancomycin TDM KR` is open to everyone. We are happy to take your input. Please fork the repo, modify the codes and submit a pull request. <https://github.com/shanmdphd/vtdm>

### Reference

This work is largely dependent on the paper published in J Clin Pharm Ther. in 2014.

- Lim HS, Chong YP, Noh YH, Jung JA, Kim YS. Exploration of optimal dosing regimens of vancomycin in patients infected with methicillin-resistant Staphylococcus aureus by modeling and simulation. J Clin Pharm Ther. 2014;39(2):196-203. <https://www.ncbi.nlm.nih.gov/pubmed/24428720>
- Rybak et al. Therapeutic monitoring of vancomycin in adult patients. American Journal of Health-System Pharmacy. 2009;66(1):82-98. <http://www.ajhp.org/content/66/1/82>
- "Clinical pharmacokinetics and pharmacodynamics: concepts and applications, 4th edition" Lippincott Williams & Wilkins. 2011. ISBN 978-0-7817-5009-7

The pharmacokinetic parameters from the paper were derived and used in the app as follows:

$$ 
\begin{split}
Creatinine\ CL & = \frac{(140-age) \cdot W (\cdot 0.85\ if\ female)}{72 \cdot Cr} \newline 
\newline
\begin{bmatrix}
\eta_1 \newline
\eta_2 \newline
\eta_3
\end{bmatrix}
& \sim MVN \bigg(
    \begin{bmatrix}
    0 \newline
    0 \newline
    0
    \end{bmatrix}
    , 
    \begin{bmatrix}
    0.120 & 0 & 0 \newline
    0 & 0.149 & 0 \newline
    0 & 0 & 0.416
    \end{bmatrix}
    \bigg) \newline
\newline
V_1\ (L) & = 33.1 \cdot e^{\eta1} \newline
V_2\ (L) & = 48.3 \newline
CL\ (L/hr) & = 3.96 \cdot \frac{CCR}{100} \cdot e^{\eta2} \newline
Q\ (L/hr) & = 6.99 \cdot e^{\eta3} \newline
\newline
k_{10}\ (/hr) & = \frac{CL}{V_1} \newline
k_{12}\ (/hr) & = \frac{Q}{V_1} \newline
k_{21}\ (/hr) & = \frac{Q}{V_2} \newline
\newline
\lambda_1 & = \frac{k_{10} + k_{12} + k_{21} + \sqrt{(k_{10} + k_{12} + k_{21})^2 - 4 \cdot k_{10} \cdot k_{21}}}{2}   \newline
\lambda_2 & = k_{10} + k_{12} + k_{21} - \lambda_1  \newline
& = k_{10} + k_{12} + k_{21} - \frac{k_{10} + k_{12} + k_{21} + \sqrt{(k_{10} + k_{12} + k_{21})^2 - 4 \cdot k_{10} \cdot k_{21}}}{2} \newline
C_1\ (mg/L) & = \frac{\lambda_1 - k_{21}}{V_1 \cdot (\lambda_1 - \lambda_2)} \newline
C_2\ (mg/L) & = \frac{k_{21} - \lambda_2}{V_1 \cdot (\lambda_1 - \lambda_2)} \newline
During\ infusion &\newline
C_p\ (mg/L) &= \frac{Rate}{\lambda_1} \cdot C_1 \cdot (1 - e^{-\lambda_1 \cdot t}) + \frac{Rate}{\lambda_2} \cdot C_2 \cdot (1 - e^{-\lambda_2 \cdot t}) \newline
After\ infusion &\newline
C_p\ (mg/L) &= \frac{Rate}{\lambda_1} \cdot C_1 \cdot (1 - e^{-\lambda_1 \cdot DUR}) \cdot e^{-\lambda_1 \cdot t} + \frac{Rate}{\lambda_2} \cdot C_2 \cdot (1 - e^{-\lambda_2 \cdot DUR}) \cdot e^{-\lambda_2 \cdot t} \newline
\end{split}
$$

(Abbreviation: $AI$, accumulation index; $AUC$, area under the plasma drug concentration-time curve; $CL$, total clearance of drug from plasma; $C_{av,ss}$, average drug concentration in plasma during a dosing interval at steady state on administering a fixed dose at equal dosing intervals; $C_{max}$, highest drug concentration observed in plasma; $Creatinine\ CL$, Cockcroft-Gault creatinine clearance(ml/min/1.73 m^2 ); $MVN$, multivariate normal distribution; $Q$, Intercompartmental clearance; $V$, Volume of distribution (apparent) based on drug concentration in plasma; $W$, body weight (kg); $\eta$, interindividual random variability parameter; $k$, elimination rate constant;  $k_a$, absorption rate constant; $\tau$, dosing interval)

### R Packages
- H. Wickham. ggplot2: Elegant Graphics for Data Analysis. Springer-Verlag New York, 2009.
- Winston Chang, Joe Cheng, JJ Allaire, Yihui Xie and Jonathan McPherson (2016). shiny: Web Application Framework for R. R package version 0.14.2. https://CRAN.R-project.org/package=shiny
- JJ Allaire, Jeffrey Horner, Vicent Marti and Natacha Porte (2015). markdown: 'Markdown' Rendering for R. R package version 0.7.7. https://CRAN.R-project.org/package=markdown
- Hadley Wickham and Romain Francois (2016). dplyr: A Grammar of Data Manipulation. R package version 0.5.0. https://CRAN.R-project.org/package=dplyr
