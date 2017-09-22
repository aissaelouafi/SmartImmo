library(solr)
library(ggplot2)
library(plotly)
library(httr)
library(jsonlite)

options(scipen=999)

solr_data <- getDataFromSolr(10000)

getDataFromSolr <- function(limit){
  url <- 'http://localhost:8983/solr/smartimmo/select'
  out <-solr_search(q='*:*', rows=limit, base=url)
  out <- out[, -grep("label_", colnames(out))]
  return(out)
}

plotDailyData <- function(){
  date_vector <- as.data.frame(as.Date(solr_data$date))
  colnames(date_vector) <- c("date")
  a <- as.data.frame(table(date_vector$date))
  colnames(a) <- c("date","count")
  p <- plot_ly(x = a$date, y = a$count, mode = 'lines')
  p <- ggplot(data=a, aes(x=date, y=count, fill=count)) +geom_bar(stat="identity") +theme(axis.text.x = element_text(angle = 90, hjust = 1))
  p <- ggplotly(p)
  return(p)
}

getAdsCategory <- function(){
  url <- "http://www.avito.ma/templates/api/confcategories.js?v=3"
  category <- GET(url = url)
  category <- content(category,"text")
  category <- as.data.frame(fromJSON(category))
  colnames(category) <- c("category","level","parent","name","type")
  category <- subset(category, select=c("category","name"))
  return(category)
}

plotByRegion <- function(){
  region_vector  <- subset(solr_data, select=c("region", "category"))
  region_vector <- merge(getAdsCategory(),region_vector,by="category")
  region_count <- as.data.frame(table(region_vector))
  region_count <- subset(region_count, select=c("name","region","Freq"))
  colnames(region_count) <- c("category","region","count")
  region_count <- region_count[order(region_count$count,decreasing = TRUE),] 
  region_count <- region_count[1:100,]
  p <- ggplot(data=region_count, aes(x=region, y=count,fill=category)) +geom_bar(stat="identity") + theme(axis.text.x = element_text(angle = 90, hjust = 1)) 
  p <- ggplotly(p)
  return(p)
}

getAdsList <- function(){
  solr_data <- merge(getAdsCategory(),region_vector,by="category")
  solr_data <- subset(solr_data, select=c("id","date","subject","body","name.x","Adresse","region","Superficie","price","url"))
  return(solr_data)
}

getPriceBySuperficie <- function(){
  price_by_region <- subset(solr_data,select=c("category","region","Superficie","price"))
  price_by_region$Superficie <- gsub('m²','',as.character(price_by_region$Superficie))
  price_by_region$price <- gsub('\\.','',price_by_region$price)
  price_by_region <- na.omit(price_by_region)
  p <- price_by_region %>%
    mutate(group = factor(cut(as.numeric(Superficie), seq(0, 300, 75)))) %>%
    group_by(region,group) %>%
    summarise(count = n()) %>%
    filter(count > 100) %>% 
    ggplot(aes(x = region, y = count, fill=group)) + theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    geom_bar(stat = "identity", position = "stack")+
    ylab("Nombre de biens")+xlab("Region")
  p <- ggplotly(p)
  return(p)
}

getPriceByRegion <- function(){
  price_by_region <- subset(solr_data,select=c("category","region","Superficie","price"))
  price_by_region$Superficie <- gsub('m²','',as.character(price_by_region$Superficie))
  price_by_region$price <- gsub('\\.','',price_by_region$price)
  price_by_region <- na.omit(price_by_region)
  p <- price_by_region %>%
    mutate(group = factor(cut(as.numeric(price), seq(0, 2000000,500000)))) %>%
    group_by(region,group) %>%
    summarise(count = n()) %>%
    filter(count > 50) %>% 
    ggplot(aes(x = region, y = count, fill=group)) + theme(axis.text.x = element_text(angle = 90, hjust = 1)) + theme(legend.position="bottom",legend.direction="vertical")+
    geom_bar(stat = "identity", position = "stack") +
    ylab("Nombre de biens")+xlab("Region")
  p <- ggplotly(p)
  return(p)
}


