library(solr)
library(ggplot2)
library(plotly)
library(dplyr)
library(httr)
library(jsonlite)

getDataFromSolr <- function(limit){
  url <- 'http://localhost:8983/solr/smartimmo/select'
  out <-solr_search(q='*:*',fl=c('id','subject','category','city','thumb','Adresse','Superficie','type','body','price','Secteur','date','url','region','Prix_Total','Nombre_de_pieces'), rows=limit, base=url)
  return(out)
}
solr_data <- getDataFromSolr(5000)

save(solr_data, file="solr_data.rda")
