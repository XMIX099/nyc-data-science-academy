library(dplyr)
library(choroplethr)
library(choroplethrMaps)
library(ggplot2)
library(openxlsx)

perkins1112 = read.xlsx('1112PerkinsCDR.xlsx')
perkins1213 = read.xlsx('1213PerkinsCDR.xlsx')
perkins1314 = read.xlsx('1314PerkinsCDR.xlsx')

names(perkins1112)
names(perkins1213)
names(perkins1314)

rename.columns =      c('Serial',
                       'OPEID',
                       'Institution.Name',
                       'Address',
                       'City',
                       'ST',
                       'Zip',
                       'Bwrs.Who.Started.Repayment.Previous.School.Year',
                       'Bwrs.In.Default.On.June30',
                       'Cohort.Default.Rate',
                       'Bwrs.In.Default.For.At.Least.240.Days',
                       'Principal.Outstanding.On.Loans.In.Default.For.At.Least.240.Days')

names(perkins1112) = names(perkins1213) = names(perkins1314) = rename.columns

perkins1112$year='11-12'
perkins1213$year='12-13'
perkins1314$year='13-14'

perkins.data = rbind(perkins1112,perkins1213,perkins1314)
nrow(perkins.data)==nrow(perkins1112)+nrow(perkins1213)+nrow(perkins1314)

sapply(perkins.data, class)

perkins.data[,
             c("Bwrs.Who.Started.Repayment.Previous.School.Year",
               "Bwrs.In.Default.On.June30",
               "Bwrs.In.Default.For.At.Least.240.Days",
               "Principal.Outstanding.On.Loans.In.Default.For.At.Least.240.Days")] = 
  sapply(perkins.data[,
                      c("Bwrs.Who.Started.Repayment.Previous.School.Year",
                        "Bwrs.In.Default.On.June30",
                        "Bwrs.In.Default.For.At.Least.240.Days",
                        "Principal.Outstanding.On.Loans.In.Default.For.At.Least.240.Days")],
         as.numeric)

#Removing % signs from values and converting to ratios.
perkins.data[,"Cohort.Default.Rate"] = 
  sapply(
    perkins.data[,"Cohort.Default.Rate"],
    (function(x) sub('%','',x)))

perkins.data[,"Cohort.Default.Rate"] = 
  sapply(
    perkins.data[,"Cohort.Default.Rate"],
    as.numeric)

perkins.data[,"Cohort.Default.Rate"] = 
  sapply(
    perkins.data[,"Cohort.Default.Rate"],
    (function(x) x/100))

data(state.regions)
perkins.data = merge(perkins.data, state.regions, by.x='ST', by.y='abb')
perkins.data = tbl_df(perkins.data)

#Looking at Borrowers and Principal for Loans in Default For More Than 240 Days
yearly.data.borrowers = group_by(perkins.data,year) %>%
  summarise(.,
            value=sum(Bwrs.In.Default.For.At.Least.240.Days))

ggplot(data=yearly.data.borrowers,aes(x=year,y=value)) +
  geom_bar(stat="identity", fill="white", colour="darkgreen") +
  geom_text(data = yearly.data.borrowers,
            aes(y=value-1e5, x=year, label = formatC(value, format="d", big.mark=','),size=8),
            color=I('blue'), show_guide  = F) +
  theme_bw() +
  ggtitle('Borrowers In Default After 240 Days') + 
  xlab('Year Of Entering Repayment Status') + 
  ylab('Number of Borrowers')

yearly.data.principal = group_by(perkins.data,year) %>%
  summarise(.,
            value=sum(Principal.Outstanding.On.Loans.In.Default.For.At.Least.240.Days))

ggplot(data=yearly.data.principal ,aes(x=year,y=value)) +
  geom_bar(stat="identity", fill="white", colour="darkgreen") +
  geom_text(data = yearly.data.principal,
            aes(y=value-1e8, x=year, label = paste('$',formatC(value, format="d", big.mark=',')),size=8),
            color=I('blue'), show_guide  = F) +
  theme_bw() +
  ggtitle('Principal Owed After 240 Days In Default') + 
  xlab('Year Of Entering Repayment Status') + 
  ylab('Total Principal Owed ($)')

#Munging for Choropleth Maps
state.pop =  read.csv('statepop.csv',stringsAsFactors = FALSE)
state.pop$State = sapply(state.pop$State,(function(x) tolower(x)))
state.pop = subset(state.pop, select = -c(Census,Estimates.Base))
state.pop[,-1] = sapply(state.pop[,-1],(function(x) gsub(',','',x)))
state.pop[,-1] = sapply(state.pop[,-1],as.numeric)
state.pop['11-12'] = ceiling((state.pop[,'X2011']+state.pop[,'X2012'])/2)
state.pop['12-13'] = ceiling((state.pop[,'X2012']+state.pop[,'X2013'])/2)
state.pop['13-14'] = ceiling((state.pop[,'X2013']+state.pop[,'X2014'])/2)
state.pop = state.pop[,c(1,7,8,9)]

states=unique(state.pop$State)
region = rep(states,3)
test = data.frame(region)
test$pop = 0 
test$year = 0 
test[1:51,2] = state.pop[,2]
test[1:51,3] = "11-12"
test[52:102,2] = state.pop[,3]
test[52:102,3] = "12-13"
test[103:153,2] = state.pop[,4]
test[103:153,3] = "13-14"

state.data = group_by(perkins.data,region,year)
state.data.with.pop = inner_join(state.data,
                                 test,
                                 by=c("region","year"))

#Choropleth Maps 1
state.data.plot.1.0 = summarise(subset(state.data.with.pop,year=='11-12'),
                             value=1000000*sum(Bwrs.In.Default.On.June30)/sum(Bwrs.Who.Started.Repayment.Previous.School.Year)/min(pop))

state_choropleth(state.data.plot.1.0,
                 title      = "Default Rate For 2012",
                 legend     = "Default Rate Per Million Inhabitants",
                 num_colors = 9)

state.data.plot.1.1 = summarise(subset(state.data.with.pop,year=='12-13'),
                             value=1000000*sum(Bwrs.In.Default.On.June30)/sum(Bwrs.Who.Started.Repayment.Previous.School.Year)/min(pop))

state_choropleth(state.data.plot.1.1,
                 title      = "Default Rate For 2013",
                 legend     = "Default Rate Per Million Inhabitants",
                 num_colors = 9)

state.data.plot.1.2 = summarise(subset(state.data.with.pop,year=='13-14'),
                                value=1000000*sum(Bwrs.In.Default.On.June30)/sum(Bwrs.Who.Started.Repayment.Previous.School.Year)/min(pop))

state_choropleth(state.data.plot.1.2,
                 title      = "Default Rate For 2014",
                 legend     = "Default Rate Per Million Inhabitants",
                 num_colors = 9)

#Choropleth Maps 2
state.data.plot.2.0 = summarise(subset(state.data.with.pop,year=='11-12'),
                                value=1000000*(sum(Principal.Outstanding.On.Loans.In.Default.For.At.Least.240.Days)/sum(Bwrs.In.Default.For.At.Least.240.Days))/min(pop))

state_choropleth(state.data.plot.2.0,
                 title      = "Principal to Borrowers Ratio For Those In Default For More Than 240 Days (2012)",
                 legend     = "Principal to Borrowers Ratio Per Million Inhabitants",
                 num_colors = 9)

state.data.plot.2.1 = summarise(subset(state.data.with.pop,year=='12-13'),
                                value=1000000*sum(Principal.Outstanding.On.Loans.In.Default.For.At.Least.240.Days)/sum(Bwrs.In.Default.For.At.Least.240.Days-Bwrs.In.Default.On.June30)/min(pop))

state_choropleth(state.data.plot.2.1,
                 title      = "Principal to Borrowers Ratio For Those In Default For More Than 240 Days (2013)",
                 legend     = "Principal to Borrowers Ratio Per Million Inhabitants",
                 num_colors = 9)

state.data.plot.2.2 = summarise(subset(state.data.with.pop,year=='13-14'),
                                value=1000000*sum(Principal.Outstanding.On.Loans.In.Default.For.At.Least.240.Days)/sum(Bwrs.In.Default.For.At.Least.240.Days)/min(pop))

state_choropleth(state.data.plot.2.2,
                 title      = "Principal to Borrowers Ratio For Those In Default For More Than 240 Days (2014)",
                 legend     = "Principal to Borrowers Ratio Per Million Inhabitants",
                 num_colors = 9)

#Scatterpoint of Data 
high.debt = subset(  perkins.data,
                     perkins.data$Principal.Outstanding.On.Loans.In.Default.For.At.Least.240.Days >= 1.5e7)

ggplot(data=perkins.data,
       aes(x=Bwrs.In.Default.For.At.Least.240.Days-200,
           y=Principal.Outstanding.On.Loans.In.Default.For.At.Least.240.Days)) +
  geom_point(col=I('blue'),size=2) +
  geom_point(data=high.debt, aes(colour = Institution.Name),size=3) +
  geom_text(data = high.debt, 
            aes(y=Principal.Outstanding.On.Loans.In.Default.For.At.Least.240.Days,
                x=Bwrs.In.Default.For.At.Least.240.Days+280,
                label = paste(ST,year,sep=', '),size=4),show_guide  = F) +
  ggtitle('Status After 240 Days In Default') +
  xlab('Number of Borrowers') +
  ylab('Principal Owed ($)') +
  scale_colour_discrete(name = "Colleges") +
  theme(legend.justification = c(1, 0), legend.position = c(1, 0)) 

#Looking At State Rankings
state.data.13.14 = group_by(subset(perkins.data,year=='13-14'),region) %>%
                      summarise(.,total.principal=sum(Principal.Outstanding.On.Loans.In.Default.For.At.Least.240.Days)) 

arrange(state.data.13.14,total.principal)
sorted.states = arrange(state.data.13.14,desc(total.principal))

#Plot 4: Most Indebted State Exploration
ny.data.13.14 = subset(perkins.data,ST=='NY' & year=='13-14')

high.debt.ny = subset(ny.data.13.14,
                      ny.data.13.14$Principal.Outstanding.On.Loans.In.Default.For.At.Least.240.Days >= 2.5e6)

ggplot(data=ny.data.13.14,
       aes(x=Bwrs.In.Default.For.At.Least.240.Days-200,
           y=Principal.Outstanding.On.Loans.In.Default.For.At.Least.240.Days)) +
  geom_point(col=I('blue'),size=2) +
  geom_point(data=high.debt.ny, aes(colour = Institution.Name),size=3) +
  ggtitle('Status After 240 Days In Default In NY') +
  xlab('Number of Borrowers') +
  ylab('Principal Owed ($)') +
  scale_colour_discrete(name = "Colleges") +
  theme(legend.justification = c(1, 0), legend.position = c(1, 0))


#Last Minute Plots

data = subset(perkins.data,ST=='CA' & year=='13-14')

debt = subset(data,
                      data$Principal.Outstanding.On.Loans.In.Default.For.At.Least.240.Days >= 2e6)

ggplot(data=data,
       aes(x=Bwrs.In.Default.For.At.Least.240.Days-200,
           y=Principal.Outstanding.On.Loans.In.Default.For.At.Least.240.Days)) +
  geom_point(col=I('blue'),size=2) +
  geom_point(data=debt, aes(colour = Institution.Name),size=3) +
  ggtitle('Status After 240 Days In Default In CA (2014)') +
  xlab('Number of Borrowers') +
  ylab('Principal Owed ($)') +
  scale_colour_discrete(name = "Colleges") +
  theme(legend.justification = c(1, 0), legend.position = c(1, 0))
  












