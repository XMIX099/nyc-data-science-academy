shinyServer(function(input, output) {
  
  #Generating the state map of executions.
  output$map = renderPlotly({
    l = list(color = toRGB("white"), width = 2)
    g = list(scope = 'usa', projection = list(type = 'albers usa'))
  
    plot_ly(state.executions, z = count,locations = State, type = 'choropleth',
          locationmode = 'USA-states', color = count, size = 10, colors = 'Purples',
          marker = list(line = l), colorbar = list(title = "Number of Executions"),
          filename="r-docs/usa-choropleth") %>%
        layout(title = 'Executions In The U.S.A Since 1977<br>(Hover for Numbers By State)', 
               geo = g)
  })
  
  #Controlling the data displayed in "Those Executed" by user input.
  
  output$table <- renderDataTable({
    data = executions[,c(2,3,5,8,18,6)]
    if (input$st != "All"){
      data = data[data$State == input$st,]
    }
    if (input$yr != "All"){
      data = data[data$Year == input$yr,]
    }
    if (input$md != "All"){
      data = data[data$Method == input$md,]
    }
    if (input$rc != "All"){
      data = data[data$Race == input$rc,]
    }
    data},
    options = list(searching = FALSE, pageLength=10, lengthChange = FALSE, ordering = FALSE,
                   scrollY = "310px", scrollCollapse = TRUE, paging = FALSE, info = FALSE)
  )
  
  #Generating the "Aggregated Plots" based on user choice.
  df2 = reactive({
    if (input$st == 'All') executions
    else filter(executions, State == input$st)
  })
  
  output$plot = renderPlot({plotData(df2(), input$feature)})
  
  plotData = function(df, type) {
    switch(type,
           
           a = ggplot(data=df,aes(x=Age)) + 
             geom_histogram(fill="white", colour="darkgreen", binwidth = 3) + 
             ylab('Frequency') + 
             ggtitle('Ages of The Executed') + 
             theme_bw() +
             theme(plot.title = element_text(size=20, face="bold", vjust=2),
                   axis.title.x = element_text(face="bold"),
                   axis.title.y = element_text(face="bold")),
           
           s = ggplot(df,aes(x=Sex)) + 
             geom_bar(fill="white", colour="darkgreen", width=.5) + 
             theme_bw() + 
             ylab('Frequency') + 
             ggtitle('Sexes of The Executed') +
             theme(plot.title = element_text(size=20, face="bold", vjust=2),
                   axis.title.x = element_text(face="bold"),
                   axis.title.y = element_text(face="bold")) +
             scale_x_discrete(labels = c('Female','Male')), 
#              geom_text(data = as.data.frame(table(df$Sex)), 
#                        aes(x = Var1, y = Freq + 50, label = Freq, size= 16), 
#                        fontface="bold", color=I('black'), show_guide = F),
           
           
           r = ggplot(df,aes(x=Race)) + 
             geom_bar(fill="white", colour="darkgreen", width=.5) + 
             theme_bw() + 
             ylab('Frequency') + 
             ggtitle('Races of The Executed') +
             theme(plot.title = element_text(size=20, face="bold", vjust=2),
                   axis.title.x = element_text(face="bold"),
                   axis.title.y = element_text(face="bold")), 
#              geom_text(data = as.data.frame(table(df$Race)), 
#                        aes(x = Var1, y = Freq + 50, label = Freq, size= 16), 
#                        fontface="bold", color=I('black'), show_guide = F),
           
           m = ggplot(df,aes(x=Method)) + 
             geom_bar(fill="white", colour="darkgreen", width=.5) + 
             theme_bw() + 
             ylab('Frequency') + 
             ggtitle('Method of Execution') +
             theme(plot.title = element_text(size=20, face="bold", vjust=2),
                   axis.title.x = element_text(face="bold", vjust=-1),
                   axis.title.y = element_text(face="bold"))
#           geom_text(data = as.data.frame(table(df$Method)), 
#           aes(x = Var1, y = Freq + 50, label = Freq, size= 16), 
#           fontface="bold", color=I('black'), show_guide = F)
    )
  }

  #Generating a time series plot for the "Summary".
  output$time.series = renderPlot({
    #plot_ly(year.executions, x = Year, y = count, name = "Executions Year On Year", filename="r-docs/basic-time-series")
    ggplot(data = year.executions, aes(x=Year,y=count)) + 
      geom_line(colour="darkgreen") + 
      ylim(0,50) +
      ggtitle('Executions Year On Year') +
      ylab('Number Executed') +
      theme_bw() + 
      theme(plot.title = element_text(size=20, face="bold", vjust=2),
            axis.title.x = element_text(face="bold", vjust=-1),
            axis.title.y = element_text(face="bold"))
  })
  
  
  

})