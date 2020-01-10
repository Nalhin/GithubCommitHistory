#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(jsonlite)
library(tm)
library(wordcloud)
library(SnowballC)
library(quantmod)
library(lubridate)
library(ggplot2)
library(dplyr)
library(DT)
    


shinyServer(function(input, output) {
      
    # Load User
  
 # {as.data.frame(fromJSON("commitData.json"))}
    commit_data_frame <- reactiveVal({
      data<- as.data.frame(fromJSON("commitData.json"))
    })
    
  
    observeEvent(input$loadUser, {
      if(!is.null(input$userName)){
        data<-as.data.frame(fromJSON(paste0("https://r-api.krzysztofolipra.com/",input$userName)))
        if(length(data)>1){
          commit_data_frame({data})
        }
      }
    })
  
    # Summary
    
  
    
    output$repositories <- 
    
      DT::renderDataTable({
      datatable( commit_data_frame() %>% 
                  group_by(repositoryName) %>%
                  summarise(
                    "Commits"= n(),
                    "Lines of code" = sum(additions)-sum(deletions),
                    "Total deletions"=sum(deletions),
                    "Total additions"=sum(additions),
                    "Top language"=language[1],
                    repositoryUrl=repositoryUrl[1],
                    languageColor=languageColor[1]
                  ) %>%
                  rename("Repository name"=repositoryName),
                options = list(
                  pageLength = 30,
                  rowCallback = JS(
                    "function(row, data) {",
                    "$('td:eq(8)',row).css({'display': 'none'});",
                    "$('td:eq(7)',row).css({'display': 'none'});",
                    "var color =$('td:eq(8)', row).text()",
                    "var href =$('td:eq(7)', row).text()",
                    "var rgbaCol = 'rgba(' + parseInt(color.slice(-6,-4),16)+ ',' + parseInt(color.slice(-4,-2),16)+ ',' + parseInt(color.slice(-2),16)+',0.5)';",
                    "$(row).css({'background-color': rgbaCol,'cursor':'pointer','color':'#000'});",
                    "$(row).click(function(){window.open(href)});",
                    "}"),
                  initComplete = JS(
                    "function(settings, json) {",
                    "$('th:contains(languageColor)').css({'display':'none'});",
                    "$('th:contains(repositoryUrl)').css({'display':'none'});",
                    "$(this.api().table().header()).css({'background-color': '#000', 'color': '#fff'});",
                    "}")
                ))
      })
                
   
    # Commits
  
    keeps <- c("committedDate","message","additions","deletions","changedFiles","language","repositoryName","languageColor","url")
    
    output$commits <-
      DT::renderDataTable({
        data<-commit_data_frame()
        datatable(
            data[keeps] %>%
            mutate(committedDate=as_date(committedDate))%>%
            arrange(desc(committedDate)) %>%
            rename(
              "Commit date"=committedDate,
              "Message"=message,
              "Repository Name"=repositoryName,
              "Additions"=additions,
              "Deletions"=deletions,
              "Changed files"=changedFiles,
              "Language"=language
            ),
        options = list(
          rowCallback = JS(
            "function(row, data) {",
            "$('td:eq(8)',row).css({'display': 'none'});",
            "$('td:eq(9)',row).css({'display': 'none'});",
            "var color =$('td:eq(8)', row).text()",
            "var href =$('td:eq(9)', row).text()",
            "var rgbaCol = 'rgba(' + parseInt(color.slice(-6,-4),16)+ ',' + parseInt(color.slice(-4,-2),16)+ ',' + parseInt(color.slice(-2),16)+',0.5)';",
            "$(row).css({'background-color': rgbaCol,'cursor':'pointer','color':'#000'});",
            "$(row).click(function(){window.open(href)});",
            "}"),
          initComplete = JS(
            "function(settings, json) {",
            "$('th:contains(languageColor)').css({'display':'none'});",
            "$('th:contains(url)').css({'display':'none'});",
            "$(this.api().table().header()).css({'background-color': '#000', 'color': '#fff'});",
            "}")
        )) 
  })
    
    # Messages
    
    prepare_words <- function(word_columns){
      text <- Corpus(VectorSource(word_columns)) %>%
        tm_map(content_transformer(tolower)) %>%
        tm_map(removePunctuation) %>%
        tm_map(stripWhitespace)
    }
    
    create_word_matrix <- function(words){
      
      dtm <- TermDocumentMatrix(words)
      m <- as.matrix(dtm)
      v <- sort(rowSums(m),decreasing=TRUE)
      d <- data.frame(word = names(v),freq=v)
    }
    
    
    
    output$wordFrequencyCloud <-  renderPlot({
      words <- create_word_matrix(prepare_words(select(commit_data_frame(),"message")))
      
      wordcloud(words = words$word[input$wordFrequencySlider[1]:input$wordFrequencySlider[2]], freq = words$freq, min.freq = 1,
                                           max.words=input$wordFrequencySlider[2], random.order=FALSE, rot.per=0.35, 
                                           colors=brewer.pal(8, "Dark2")) })
    
    output$wordFrequencyPlot <- renderPlot({
        words <- create_word_matrix(prepare_words(select(commit_data_frame(),"message")))
      
        barplot(words[input$wordFrequencySlider[1]:input$wordFrequencySlider[2],]$freq, 
                las = 3, 
                names.arg = words[input$wordFrequencySlider[1]:input$wordFrequencySlider[2],]$word,
                col ="skyblue", main ="Most frequently used words in commit messages",
                ylab = "Word occurance frequencies")
    })
       
    
    # Activity
    
   
    
    output$repository <- renderUI({
        
        select<-commit_data_frame() %>% distinct(repositoryName)%>%
            select(repositoryName) %>%
            rename(Repository=repositoryName) %>%
            add_row(Repository="All")
        
        selectInput("repository","Repository",select,selected="All")
    })
    
  
    filtered_count<- reactive({
        commit_data_frame() %>% 
            mutate(committedDate=as_date(committedDate))  %>%
            filter(committedDate >= input$activityPeriod[1] & committedDate <= input$activityPeriod[2]) %>%
            filter(
                if(!is.null(input$repository) && input$repository!="All") {
                    repositoryName==input$repository 
                }
                else{
                    T
                }
                )
    })
    
    
    output$totalCount <- renderText({
      between<- paste("between",
                      input$activityPeriod[1],
                      " and ",
                      input$activityPeriod[2],"equals ")
      
        if(is.null(input$repository) || input$repository=="All") {
            paste("Total commit count for all repositories ",
                  between,
                  nrow(filtered_count()))
        }
        else{
            paste("Total commit count for ",
                  input$repository,
                  between,
                  nrow(filtered_count()))
        }
    })
        
    output$activityChart <- renderPlot({
   
        parsed_count <- filtered_count()  %>%
            group_by(committedDate) %>%
            count(committedDate)
        
        ggplot( parsed_count, aes( committedDate, n, color=factor(n) )) + 
            geom_point() + 
            xlab("Date") + 
            ylab("Commit count")+ 
            labs(color="Commit count") + 
            ggtitle("Activity by date")
    
    })
    
    output$activityByMonth <-renderPlot({
        by_month <-filtered_count() %>%
            mutate(committedDate=month(committedDate,label = TRUE, abbr = FALSE)) %>%
            group_by(committedDate) %>%
            count(committedDate)
        
        
        ggplot( data= by_month, aes(committedDate,n)) + 
            geom_histogram(fill="skyblue",stat="identity") +
            ggtitle("Commits per month") +
            xlab("Month") + 
            ylab("Commit count") 

    })
    
    output$linesPerMonth <-renderPlot({
      by_month <-filtered_count() %>%
        mutate(committedDate=month(committedDate,label = TRUE, abbr = FALSE)) %>%
        group_by(committedDate) %>%
        summarise(additions = sum(additions))
      
      
      ggplot( data= by_month, aes(committedDate,additions)) + 
        geom_histogram(fill="skyblue",stat="identity") +
        ggtitle("Lines of code written per month") +
        xlab("Month") + 
        ylab("Lines of code") 
    })
})

