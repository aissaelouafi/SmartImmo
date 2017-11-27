library(solr)
library(ggplot2)
library(plotly)
library(dplyr)
library(httr)
library(jsonlite)

getDataFromSolr <- function(limit){
  url <- 'http://localhost:8983/solr/smartimmo/select'
  out <-solr_search(q='*:*', rows=limit, base=url)
  return(out)
}
solr_data <- getDataFromSolr(1000)
save(solr_data, file="solr_data.rda")
