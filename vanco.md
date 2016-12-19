
$$ 
\begin{split}
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
    1.20 \cdot 10^{-1} & 0 & 0 \newline
    0 & 1.49 \cdot 10^{-1} & 0 \newline
    0 & 0 & 4.16 \cdot 10^{-1}
    \end{bmatrix}
    \bigg) \newline
\newline
V_1\ (L) & = 33.1 \cdot e^{\eta1} \newline
V_2\ (L) & = 48.3 \newline
CL\ (mg/L) & = 3.96 \cdot \frac{CCR}{100} \cdot e^{\eta2} \newline
Q\ (1/hr) & = 6.99 \cdot e^{\eta3} \newline
\newline
k_{10}\ (/hr) & = \frac{CL}{V_1} \newline
k_{12}\ (/hr) & = \frac{Q}{V_1} \newline
k_{21}\ (/hr) & = \frac{Q}{V_2} \newline
\newline
AUC\ (mg \cdot hr / L)  & = \frac{Dose}{CL} \newline
\newline
\lambda_1 & = \frac{k_{10} + k_{12} + k_{21} + \sqrt{(k_{10} + k_{12} + k_{21})^2 - 4 \cdot k_{10} \cdot k_{21}}}{2}   \newline
\lambda_2 & = k_{10} + k_{12} + k_{21} - \lambda_1  \newline
& = k_{10} + k_{12} + k_{21} - \frac{k_{10} + k_{12} + k_{21} + \sqrt{(k_{10} + k_{12} + k_{21})^2 - 4 \cdot k_{10} \cdot k_{21}}}{2} \newline
C_1 & = \frac{\lambda_1 - k_{21}}{V_1 \cdot (\lambda_1 - \lambda_2)} \newline
C_2 & = \frac{k_{21} - \lambda_2}{V_1 \cdot (\lambda_1 - \lambda_2)} \newline
C_p & = Dose \cdot (C_1 \cdot e^{-\lambda_1 \cdot t} + C_2 \cdot e^{-\lambda_2 \cdot t})

\end{split}
$$
