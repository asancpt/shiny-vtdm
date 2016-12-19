#library(rsconnect)
rsconnect::setAccountInfo(name='asan', token='12696AD7B41ABFC67799183BF75ED7CF', secret='G+dZqQWocJu2ZFeFoWV6wQgYopp5YXdXh8+IbFYo')
install.packages("ggforce")
rsconnect::deployApp(appDir = "~/GIT/shiny/caff", appName = 'caff', account='asan')

# This only works in Rstudio - 2016-12-03
#library(shiny)



# devtools::install_github("hadley/dplyr", force = TRUE)
# devtools::install_github('davidgohel/ggiraph', force = TRUE)
# devtools::install_github("cardiomoon/ggiraphExtra", force = TRUE)
# devtools::install_github("davidgohel/gdtools")
# devtools::install_github("dkahle/ggmap")
