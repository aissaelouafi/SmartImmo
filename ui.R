## app.R ##
library(shinydashboard)
library(plotly)
library(DT)
library(sunburstR)
library("shinycssloaders", lib.loc="/Library/Frameworks/R.framework/Versions/3.3/Resources/library")

ui <- dashboardPage(
  dashboardHeader(title = "Smart Immobillier"),
  dashboardSidebar( 
    sidebarMenu(
      menuItem("Tableau de bord", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Terrains",tabName = "terrain",icon = icon("dashboard")),
      menuItem("Carte",tabName = "map",icon=icon("map-marker")),
      menuItem("Estimateurs",tabName = "estimatos",icon=icon("eur"))
  )),
  
  
  dashboardBody(
    tabItems(
      # First tab content
      tabItem(tabName = "dashboard",
              
              h2("Tableau de bord"),
              
              fluidRow(
                box(title="Filtres", width=12,column(selectInput("type_de_bien_filter", "Type du bien :", choices = c(""),multiple=TRUE,selected="",width = NULL),width=3),
                    column(selectInput("region_filter","Region :",choices = "",width = NULL,multiple = TRUE, selected = "Agadir"),width=3),
                    
                    column(sliderInput("slider", "Prix (10k Dhs): ", 10, 300, 15),width = 3),
                    column(sliderInput("slider", "Superficie (m²):", 50, 500, 50),width = 3),collapsible = TRUE)
              ),
              fluidRow(
                box(title="Offres quotidiennes",withSpinner(sunburstOutput("sunburst_plot")),width=5, collapsible = TRUE),
                box(title="Offres quotidiennes",withSpinner(plotlyOutput("daily_plot")),width=7, collapsible = TRUE)
                
              ),            

              fluidRow(
                box(title="Offres par région",withSpinner(plotlyOutput("region_plot")), width=12, collapsible = TRUE)
              ),
              
              fluidRow(
                box(title = "Offres par secteur", withSpinner(plotlyOutput("secteur_plot")), width = 12, collapsible = TRUE)
              ),
              
              fluidRow(
                box(title="Offres par superficie",withSpinner(plotlyOutput("superficie_plot")), width=12, collapsible = TRUE)
              ),
              
              fluidRow(
                box(title="Offres par prix",withSpinner(plotlyOutput("prix_plot")), width=12, collapsible = TRUE)
              ),
              
              
              fluidRow(
                box(title = "Liste des annonces",withSpinner(DT::dataTableOutput('tbl')),width = 12, collapsible = TRUE)
              )
      ),
      
      
      tabItem(tabName = "map",
              h2("Carte"),
              fluidRow(
                box(title = "Carte des annonces",withSpinner(plotlyOutput('map')),width = 12, collapsible = TRUE)
              )
      ),
      
      
      tabItem(tabName = "estimatos",
              h2("Estimateurs"),
              fluidRow(
                box(title="Estimateur de prix",
                column(selectInput("ville", "Ville ", 10, 300, 15),width = 12),
                column(selectInput("region_bien", "Region ", 10, 300, 15),width = 12),
                column(selectInput("ville_bien", "Zone ", 10, 300, 15),width = 12),
                column(selectInput("adresse_bien", "Adresse ", 10, 300, 15),width = 12),
                column(selectInput("ville_superficie", "Superficie ", 10, 300, 15),width = 12),
                column(selectInput("nb_pieces", "Nombre de pieces ", 10, 300, 15),width = 12),
                column(actionButton("price_estimator","Estimer"),width = 12),width=12)
              )
      ),
      
      tabItem(tabName = "terrain",
              h2("Terrains"),
              fluidRow(
                box(title="Filtres", width=12,
                    column(selectInput("region_filter_terrains","Region :",choices = "",width = NULL,multiple = TRUE, selected = ""),width=4),
                    column(sliderInput("slider", "Prix (10k Dhs): ", 10, 300, 15),width = 4),
                    column(sliderInput("slider", "Superficie (m²):", 50, 500, 50),width = 4),collapsible = TRUE)
              ),
              fluidRow(
                box(title="Prix des terrains par secteur",width = 12,withSpinner(plotlyOutput("prix_terrain")),collapsible = TRUE)
              ),
              fluidRow(
                box(title="Prix des biens immobiliers par secteur",width = 12,withSpinner(plotlyOutput("prix_bien")),collapsible = TRUE)
              ),
              fluidRow(
                box(title="Prix des Appartements par secteur",width = 12,withSpinner(plotlyOutput("prix_appartements")),collapsible = TRUE)
              ),
              fluidRow(
                box(title="Prix des Maisons et villas par secteur",width = 12,withSpinner(plotlyOutput("prix_maisons_villas")),collapsible = TRUE)
              ),
              fluidRow(
                box(title="Prix des Magasins, Commerces et Locaux industriels par secteur",width = 12,withSpinner(plotlyOutput("prix_magasins")),collapsible = TRUE)
              ),
              fluidRow(
                box(title="Terrais par secteur",width = 12,withSpinner(plotlyOutput("freq_terrain")),collapsible = TRUE)
              ))
    )
  )
)


