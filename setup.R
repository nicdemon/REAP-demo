# Install dependencies
install.packages(c("rsconnect","shiny","plotly","tidyverse","flexboard","plyr","reshape2","flexdashboard","shinyWidgets","markdown"))

# Setup RSconnect
library(rsconnect)
rsconnect::setAccountInfo(name="<ACCOUNT>", token="<TOKEN>", secret="<SECRET>") # Info can found at https://www.shinyapps.io/admin/#/tokens
