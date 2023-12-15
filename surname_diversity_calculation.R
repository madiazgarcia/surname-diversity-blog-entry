#This script can be used to calculate surname diversity on any geographical level following Buonnano and Vanin (2017)
#Authors: Manuel Diaz Garcia, Jonas Elis
#Date: 2023/12/13
#Notes:
	#(1) See Buonnano and Vanin (2017) for details.
	#(2) Please take note of authors who created packages used in this script.
	#(3) Example refers to use of a STATA data set, can easily be adapted to Excel, text data.
#Legend:
	#PATH = your file path
	#SURNAME = data column that contains surname on which index calculation is based
	#GEOUNIT = data column identifying geographical unit
	#OUTPUT = output data

#Install packages
install.packages("vegan")
install.packages("readxl")
install.packages("tidyverse")
install.packages("viridis")
install.packages("viridisLite")
install.packages("foreign")
library(vegan)
library(readxl)
library(tidyverse)
library(viridis)
library(viridisLite)
library(foreign)
library(haven)

#Insert data path
path <- "PATH/FILE.XY" 

data <- read_dta(path)

#Alternative:
#data <- read_excel(path = path,
                  # col_names = TRUE)

#Count of surnames in a district
data_new <- data %>%
  group_by(SURNAME, GEOUNIT) %>%
  summarize(n = n())

#Calculating Shannon's Diversity Index and create diversity_data with index for GEOUNIT
#Shannon's Diversity Index: Lower values indicate lower diversity, Higher values indicate higher diversity
install.packages("plyr")
library(plyr)

diversity_data <- data.frame(Diversity = integer(),
                             GEOUNIT = character())

for(i in data_new$GEOUNIT){
  diversity <- data_new %>%
    filter(GEOUNIT == i) %>%
    summarize(diversity = diversity(n)) %>%
    mutate(GEOUNIT = i)
  diversity_data[nrow(diversity_data) + 1, ] <- diversity
}

detach("package:plyr", unload = TRUE)

diversity_data <- unique(diversity_data) #Unique data points
diversity_data <- rename(diversity_data, OTNAME = GEOUNIT)
View(diversity_data)

#Minimum to maximum standardization
range01 <- function(x){(x-min(x))/(max(x)-min(x))}
diversity_data$Diversity <- range01(diversity_data$Diversity)

write.dta(diversity_data, "OUTPUT.dta")