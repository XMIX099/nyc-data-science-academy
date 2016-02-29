#Data to be used in ui.R and server.R
library(dplyr)
library(shiny)
library(plotly)
library(ggplot2)

source("plotlyGraphWidget.R")
executions = read.csv('data/executions.data.final.csv')

state.executions = group_by(executions,State) %>% summarise(.,count=n())
year.executions = group_by(executions,Year) %>% summarise(.,count=n())

states = append('All', as.character(unique(executions$State)))
methods = append('All', as.character(unique(executions$Method)))
years = sort(as.character(unique(executions$Year)))
years = append('All', years)
races = append('All', as.character(unique(executions$Race)))