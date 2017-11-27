library(solr)
library(ggplot2)
library(plotly)
library(httr)
library(jsonlite)
library(sunburstR)
library(plyr)
options(scipen=999)


load("./solr_data.rda")


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

plotBySecteur <- function(city){
  solr_data_vectors <- subset(solr_data, select=c("city","region","id"))
  counts <- plyr::ddply(solr_data_vectors, .(solr_data_vectors$city, solr_data_vectors$region), nrow)
  counts <- as.data.frame(counts)
  colnames(counts) <- c("city","region","freq")
  counts <- counts[counts$region == city,]
  p <- ggplot(data=counts, aes(x=city, y=freq,fill=city)) +geom_bar(stat="identity") + theme(axis.text.x = element_text(angle = 90, hjust = 1)) 
  p <- ggplotly(p)
  return(p)
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
library(dplyr)


plotBySecteurCategory  <- function(city){
  region_vector_count  <- subset(solr_data, select=c("region", "category","city"))
  region_vector_count <- merge(getAdsCategory(),region_vector_count,by="category")
  region_vector_count <- region_vector_count[region_vector_count$region == city,]
  counts <- plyr::ddply(region_vector_count, .(region_vector_count$city, region_vector_count$name), nrow)
  counts <- as.data.frame(counts)
  colnames(counts) <- c("city","category","freq")
  p <- ggplot(data=counts, aes(x=city, y=freq,fill=category)) +geom_bar(stat="identity") + theme(axis.text.x = element_text(angle = 90, hjust = 1)) 
  p <- ggplotly(p)
  return(p)
}




getAdsList <- function(){
  #solr_data <- merge(getAdsCategory(),region_vector,by="category")
  solr_data <- subset(solr_data, select=c("id","date","subject","body","category","Adresse","region","Superficie","price","url"))
  return(solr_data)
}

getPriceBySuperficie <- function(region = NULL){
  if(is.null(region) == FALSE){
    solr_data <- solr_data[solr_data$region == region,]
  }
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


getSecteur <- function(){
  url <- "http://www.avito.ma/templates/api/confregions.js?v=3"
  secteurs <- GET(url = url)
  secteurs <- content(secteurs,"text")
  secteurs <- as.data.frame(fromJSON(secteurs))
  secteurs <- subset(secteurs, select=c("regions.id","regions.name"))
  colnames(secteurs) <- c("Secteur","secteur_name")
  secteurs$Secteur <- as.integer(as.character(secteurs$Secteur))
  return(secteurs)
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

getSunburst <- function(region = NULL){
  if(is.null(region) == FALSE){
    solr_data <- solr_data[solr_data$region == region,]
  }
  solr_data <- merge(getAdsCategory(),solr_data,by="category")
  data <- paste0(solr_data$region,"-",solr_data$name.x,"-",solr_data$city,"-",solr_data$price)
  data <- as.data.frame(data)
  data <- as.data.frame(table(data))
  return(sunburst(data,percent = TRUE,count = TRUE))
}



# function to produce summary statistics (mean and +/- sd), as required for ggplot2
data_summary <- function(x) {
  mu <- mean(x)
  sigma1 <- mu-sd(x)
  sigma2 <- mu+sd(x)
  return(c(y=mu,ymin=sigma1,ymax=sigma2))
}

prixTerrainByRegion <- function(region){
  #p <- ggplot(data=solr_data, aes(x=city, y=price, fill=city)) + 
  #  geom_violin() + stat_summary(fun.data=data_summary)
  solr_data <- solr_data[solr_data$category == 1080,]
  solr_data$Superficie <- as.numeric(gsub('m²','',as.character(solr_data$Superficie)))
  solr_data$price <- as.numeric(gsub('\\.','',solr_data$price))
  solr_data$price_stat <- solr_data$price/solr_data$Superficie
  
  if(is.null(region) == FALSE){
    solr_data <- solr_data[solr_data$region == region,]
    solr_data$price <- as.numeric(gsub('\\.','',as.character(solr_data$price)))
    p <- ggplot(data=solr_data, aes(x=city, y=price_stat, fill=city)) + 
      geom_crossbar(stat="summary", fun.y=data_summary, fun.ymax=max, fun.ymin=min) + theme(axis.text.x = element_text(angle = 90, hjust = 1))
    
  } else {
    p <- ggplot(data=solr_data, aes(x=region, y=price_stat, fill=region)) + 
      geom_crossbar(stat="summary", fun.y=data_summary, fun.ymax=max, fun.ymin=min) + theme(axis.text.x = element_text(angle = 90, hjust = 1))
    
    }
  p <- ggplotly(p)
  return(p)
}