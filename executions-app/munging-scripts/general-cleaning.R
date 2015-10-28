#Shiny Project Data Cleaning

setwd('C:/Users/Gordon/Documents/Bootcamp/projects/project2/my-app')
executions = read.csv('data/executions.data.final.csv')
#executions = read.csv('data/executions.csv')
executions[executions==''] = NA
sum(is.na(executions))

library(VIM)
missings = aggr(executions)
missings

executions$Date = strptime(x = as.character(executions$Date),format = "%d/%m/%Y")
executions$Day = executions$Date$mday        
executions$Month = executions$Date$mon + 1     
executions$Year = executions$Date$year + 1900 

write.csv(executions, "C:/Users/Gordon/Documents/Bootcamp/projects/project2/my-app/data/executions.data.final.csv", row.names=FALSE)
