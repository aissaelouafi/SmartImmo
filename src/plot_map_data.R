library(solr)
library(ggplot2)
library(plotly)
library(httr)
library(RJSONIO)
library(jsonlite)

options(scipen=999)


secteurs_id <- getSecteur()

geocodeAddress <- function(address) {
  url <- "http://maps.google.com/maps/api/geocode/json?address="
  url <- URLencode(paste(url, address, "&sensor=false", sep = ""))
  x <- fromJSON(url, simplify = FALSE)
  if (x$status == "OK") {
    out <- c(x$results[[1]]$geometry$location$lng,
             x$results[[1]]$geometry$location$lat)
  } else {
    out <- NA
  }
  Sys.sleep(0.2)  # API only allows 5 requests per second
  out
}



library(ggplot2)
library(ggmap)
library(maps)
library(mapdata)

usa <- map_data("usa")
states <- map_data("state")

getMap <- function(){
p <- ggplot(data = states) + 
  geom_polygon(aes(x = long, y = lat, fill = region, group = group), color = "white") + 
  coord_fixed(1.3) +
  guides(fill=FALSE)
  return(ggplotly(p))
}
