shinyUI(navbarPage('US Executions', id='nav',
                   
        tabPanel('State Map', plotlyOutput("map")),
        
        tabPanel('Explore',
                 fluidPage(
                   
                  sidebarPanel(
                    selectInput("st", 
                                "Choose A State", 
                                choices = states, 
                                selected = states[1]),
                    helpText("The dropdown boxes below apply to \"Those Executed\" and the buttons are for the \"Aggregated Plots\".
                             The choice of state is for both."),
                    selectInput("yr", 
                                "Choose A Year", 
                                choices = years, 
                                selected = years[1]),
                    selectInput("md", 
                                "Choose A Method", 
                                choices = methods, 
                                selected = methods[1]),
                    selectInput("rc", 
                                "Choose A Race", 
                                choices = races, 
                                selected = races[1]),
                    radioButtons('feature', 
                                'Choose a Feature To Plot',
                                  c('Age' = 'a', 'Sex' = 's', 'Race' = 'r', 'Method' = 'm'))
                 ),
                 
                 mainPanel(
                   tabsetPanel(
                     tabPanel("Those Executed", dataTableOutput('table')),
                     tabPanel("Aggregated Plots", plotOutput("plot")),
                     tabPanel("Summary", plotOutput('time.series'))
                   )
                 )
                 
                )
              ),
        
        tabPanel('About',
                 h4("Description"),
                 br(),
                 p("Blurb: This app displays various data on those executed in the United States since 1977."),
                 p(" Data Source: ",a("Death Penalty Information Center",href=
                                  "http://www.deathpenaltyinfo.org/views-executions")),
                 br(),
                 p("Author: Gordon Fleetwood"),
                 p("Github: Coming Soon"), #, a("https://github.com/gfleetwood",href="https://github.com/gfleetwood")),
                 p("Slides:", a("http://slides.com/gfleetwood/nycdsa-executions",href="http://slides.com/gfleetwood/nycdsa-executions#/")),
                 br()
                 )
  )
)
