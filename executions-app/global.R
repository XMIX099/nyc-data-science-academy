#Data to be used in ui.R and server.R
library(dplyr)
library(shiny)
library(plotly)
library(ggplot2)

#py <- plotly(username="Razinho", key="xrewy9o2vv", base_url="https://plot.ly")
source("plotlyGraphWidget.R")
#setwd('C:/Users/Gordon/Documents/Bootcamp/projects/project2/my-app')
executions = read.csv('data/executions.data.final.csv')

state.executions = group_by(executions,State) %>% summarise(.,count=n())
year.executions = group_by(executions,Year) %>% summarise(.,count=n())

states = append('All', as.character(unique(executions$State)))
methods = append('All', as.character(unique(executions$Method)))
years = sort(as.character(unique(executions$Year)))
years = append('All', years)
races = append('All', as.character(unique(executions$Race)))