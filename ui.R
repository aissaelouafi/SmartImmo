## app.R ##
library(shinydashboard)
library(plotly)
library(DT)

ui <- dashboardPage(
  dashboardHeader(title = "Smart Immobillier"),
  dashboardSidebar( 
    sidebarMenu(
      menuItem("Tableau de bord", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Carte",tabName = "map",icon=icon("map-marker")),
      menuItem("Estimateurs",tabName = "estimatos",icon=icon("eur"))
  )),
  
  
  dashboardBody(
    tabItems(
      # First tab content
      tabItem(tabName = "dashboard",
              
              h2("Tableau de bord"),
              
              fluidRow(
                box(title="Filtres", width=12,column(selectInput("type_de_bien_filter", "Type du bien :", choices = c(""),multiple=TRUE,selected="",width = NULL),width=2),
                    column(selectInput("ville_filter","Ville :",choices = c(""),width = NULL,multiple = TRUE, selected = ""),width=2),
                    column(selectInput("region_filter","Region :",choices = c("Agadir","Marrakech"),width = NULL,multiple = TRUE, selected = "Agadir"),width=2),
                    
                    column(sliderInput("slider", "Prix (10k Dhs): ", 10, 300, 15),width = 3),
                    column(sliderInput("slider", "Superficie (m²):", 50, 500, 50),width = 3),collapsible = TRUE)
              ),
              
              fluidRow(
                box(title="Offres quotidiennes",plotlyOutput("daily_plot"),width=12, collapsible = TRUE)
              ),
              
              fluidRow(
                box(title="Offres par région",plotlyOutput("region_plot"), width=12, collapsible = TRUE)
              ),
              
              fluidRow(
                box(title="Offres par superficie",plotlyOutput("superficie_plot"), width=12, collapsible = TRUE)
              ),
              
              fluidRow(
                box(title="Offres par prix",plotlyOutput("prix_plot"), width=12, collapsible = TRUE)
              ),
              
              
              fluidRow(
                box(title = "Liste des annonces",DT::dataTableOutput('tbl'),width = 12, collapsible = TRUE)
              )
      ),
      
      
      tabItem(tabName = "map",
              h2("Carte")
      ),
      
      
      tabItem(tabName = "estimatos",
              h2("Estimateurs")
      )
      
      
    )
  )
)


