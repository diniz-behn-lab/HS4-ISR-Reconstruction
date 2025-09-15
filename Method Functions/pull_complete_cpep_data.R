library(readxl)
pull_complete_cpep_data <- function(excel_file) {
  
  # Read the Excel file into a data frame
  data <- read_excel(excel_file)
  
  # Remove rows/participants with any NA values in Cpep sampling data 
  # columns 47-65 in template version of data. 
  data = data[data$`Cpep0min` != 0,]
  data = data[data$`Cpep15min` != 0,]
  data = data[data$`Cpep30min` != 0,]
  data = data[data$`Cpep60min` != 0,]
  data = data[data$`Cpep90min` != 0,]
  data = data[data$`Cpep120min` != 0,]
  data = data[data$`Cpep180min` != 0,]
  #Can perhaps condense line above into single line
  # like below where omits NA entries in columns.
  CPEP_COLS = c("Cpep0min","Cpep15min","Cpep30min","Cpep60min","Cpep90min","Cpep120min","Cpep180min")
  data <- data[complete.cases(data[,CPEP_COLS]), ]
  return(data)
}
