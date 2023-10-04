library(readr)
library(tm)
library(gsubfn)
library(dplyr)

#load in data ----
setwd("~/R/KivaAnalytics/Kiva/data") ###set directory path
source('./code/load_loans.R') # load the load-loans file
kiva_loans = load_loans('./loans') # set path to .tar.gz data files
rm(load_loans)

#prepare model ready data ----
setwd("~/Repos/paper-textprediction")

###extract required variables
my_vars <- c('whySpecial', 'use', 'description', 'status', 'fundraisingDate', 'raisedDate')
data <- kiva_loans[,my_vars]
rm(my_vars)

##filter only funded items
data <- data[data$status == 'funded',]


###clean date data

data <- data[!is.na(data$fundraisingDate),]
data <- data[!is.na(data$raisedDate),]
data <- data[data$fundraisingDate <= data$raisedDate,]

data$fundraisingDate =  gsub("*T", " ", data$fundraisingDate)
data$fundraisingDate =  gsub("*Z", "", data$fundraisingDate)
data$fundraisingDate =  as.Date(data$fundraisingDate)

data$raisedDate =  gsub("*T", " ", data$raisedDate)
data$raisedDate =  gsub("*Z", "", data$raisedDate)
data$raisedDate =  as.Date(data$raisedDate)

##calc mean and use as a target variable
data$tte <- as.numeric(data$raisedDate - data$fundraisingDate)
funded_tte <- quantile(data$tte, probs = c(.25, .50, .75, .95))

data$target2 <- 0
data$target2[data$tte > unname(funded_tte['50%'])] <- 1

data$target4 <- 0
data$target4[data$tte > unname(funded_tte['25%'])] <- 1
data$target4[data$tte > unname(funded_tte['50%'])] <- 2
data$target4[data$tte > unname(funded_tte['75%'])] <- 3

##save file
write.csv(data, file = './data/measures.csv', row.names = F)


##preprocess string variables to one variable ----
# extract key text variables
Kiva_text <- data[,c("whySpecial","use","description")] 

# convert variables all to character form ----
Kiva_text_char <- c(lapply(Kiva_text,as.character)) ###convert variables all to character form

tail(Kiva_text_char$description)

#create text document
temp  <- mapply(paste0, Kiva_text_char$whySpecial,Kiva_text_char$use, SIMPLIFY = TRUE )
Document_Kiva_text <- mapply(paste0, temp ,Kiva_text_char$description, SIMPLIFY = TRUE )
remove(temp)

###add to dataframe
data$text <- Document_Kiva_text

###create a text vs class binary dataframe and save
binary_data <- data[,c("text", "target2")]
colnames(binary_data) = c('text','class')

write.csv(data ,file=gzfile("./data/binary_data.csv"))
###create a text vs class binary dataframe and save
quartile_data <- data[,c("text", "target4")]
colnames(quartile_data) = c('text','class')

write.csv(data ,file=gzfile("./data/quartile_data.csv"))
