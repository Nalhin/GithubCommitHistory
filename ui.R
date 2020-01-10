#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinythemes)
library(DT)


load_user_page <-mainPanel(
    div(style="font-size:24px;
        padding-bottom:24px;",
        textOutput("userStatus")
    ),
    textInput("userName", "User Name"),
    actionButton("loadUser", "Load different user"),
    textOutput("loading"),
    div(style="font-size:20px;
        color:red;
        padding-top:8px;",
        textOutput("loadError"),
    ),
    width = 12
)

repositories_page<-
    mainPanel(
        DT::dataTableOutput("repositories"),
        width = 12
    )

commit_page<-  basicPage(
   mainPanel(
        DT::dataTableOutput("commits"),
        width = 12
    )
)

message_page <- sidebarLayout(
    
    sidebarPanel(
        sliderInput("wordFrequencySlider", "Selected range (Descending order):", min=1, max=400, value=c(1,20))
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
        plotOutput("wordFrequencyCloud"),
        plotOutput("wordFrequencyPlot")
    )
)

activity_page <-sidebarLayout(
    sidebarPanel(
        dateRangeInput("activityPeriod","Activity period",  format = "yyyy-mm-dd",min="2015-01-01",start="2019-09-01"),
        uiOutput("repository")
    ),
    mainPanel(
        div(style="font-size:24px;
                    text-align:center;",
        textOutput("totalCount")
        ),
        plotOutput("activityChart"),
        plotOutput("activityByMonth"),
        plotOutput("linesPerMonth")
    )
)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
    shinythemes::themeSelector(),
    
    # Application title
    navbarPage("Github Commit History",
               tabPanel("Load user",load_user_page),
               tabPanel("Repositories",repositories_page),
               tabPanel("Commits",commit_page),
               tabPanel("Messages",message_page),
               tabPanel("Activity",activity_page)
    ),
))



