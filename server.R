
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

source("src/extract_data.R")
library(shiny)
library(plotly)
library(DT)

shinyServer(function(input, output,session) {
  output$daily_plot <- renderPlotly({
    plotDailyData()
  })
  
  updateSelectInput(session,"region_filter",choices = unique(solr_data$region))
  
  output$secteur_plot <- renderPlotly({
    plotBySecteur(input$region_filter)
  })
  
  output$sunburst_plot <- renderSunburst({
    getSunburst()
  })
  
  output$region_plot <- renderPlotly({
    plotByRegion()
  })
  output$superficie_plot <- renderPlotly({
    getPriceBySuperficie()
  })
  
  output$prix_plot <- renderPlotly({
    getPriceByRegion()
  })
  
  output$map <- renderPlotly({
    getMap()
  })
  
  output$tbl <- DT::renderDataTable(filter = "top",{
    getAdsList()
  }, options = list(lengthChange = FALSE, pageLength = 200))
  
  ## Terrains
  output$prix_terrain <- renderPlotly({
    prixTerrainByRegion(region = NULL)
  })
  
  
  
  observeEvent(input$region_filter, {
    print(input$region_filter)
    region <- input$region_filter
    output$secteur_plot <- renderPlotly({
      plotBySecteur(region)
    })
    
    
    output$region_plot <- renderPlotly({
      plotBySecteurCategory(region)
    })
    
    output$sunburst_plot <- renderSunburst({
      getSunburst(input$region_filter)
    })
    
    output$superficie_plot <- renderPlotly({
      getPriceBySuperficie(input$region_filter)
    })
    
  }, ignoreInit = TRUE)
  
  
  ## Terrains
  observeEvent(input$region_filter_terrains,{
    output$prix_terrain <- renderPlotly({
      prixTerrainByRegion(region = input$region_filter_terrains)
    })
  })
  
  
  updateSelectInput(session,"ville_filter",choices = unique(solr_data$region), selected =unique(solr_data$region)[1] )
  updateSelectInput(session,"region_filter_terrains",choices = unique(solr_data$region), selected =unique(solr_data$region)[1] )
  #updateSelectInput(session,"type_de_bien_filter",choices = unique(region_vector$name.x), selected =unique(region_vector$name.x)[1] )
  
})
