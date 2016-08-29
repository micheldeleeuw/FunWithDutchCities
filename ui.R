#
#
# ui.R, the user interface file for our shiny app.
# 28/08/2016, Michel de Leeuw, version 1.1
#
# See ajoining server.R file for mor information
#

library(shiny)
# Leaflet is used for displaying the map
library(leaflet)
# GoogleVis is used of displaying the table of selected ranks
library(googleVis)

# We use a fluid page for our application
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Having fun with Dutch cities"),
  tags$hr(),
  
  # Sidebar with the text and the results
  sidebarLayout(
    sidebarPanel(
      # Only show the new city button at the start of the game
      # Actually, you could use it again, but because of a small bug, it is only shown at the start.
      conditionalPanel(
        condition = "input.newcity == 0",
        h5("Hit the button to select a city to (re)start the game."),
       actionButton("newcity", "Select city"), br(), br()),
       # Only show information for the selected city when a city is selected
       conditionalPanel(
         condition = "input.newcity > 0",
         h5("You selected"),
         h3(textOutput("selected_city")), br(),
         h5("When ranked on a list of the 25 biggest Dutch cities (with 1 being Amsterdam, the biggest city) where do think it stands?"),
         selectInput("yourguess", "Your guess", 1:25),
         actionButton("guess", "Validate guess"), br(), br()
       ),
       # Only show the results after the first guess
       conditionalPanel(
         condition = "input.guess > 0",
         h4(textOutput("guess_result")), br(),
         h5("Your guesses:"), 
         uiOutput('choosen_cities_table')
       )
    ),
    
    # On the main panel (on the right) we show a map of The Netherlands with the selected city/cities
    mainPanel(
      # When there is no city selected yet, we display the documentation
      conditionalPanel(
        # Only show the manual at the start of the game
        condition = "input.newcity == 0",
        h2("Welcome to the 'Having fun with Dutch cities' game."),
        h4("This simple game is created for the peer graded assignment for the Coursera Data Science Course - Developing Data Products"), br(),br(),
        h5("Manual:"),
        tags$ul(
          h5(tags$li("The app is a small game that lets you guess the ranking of a randomly choosen Dutch city (top 25).")),
          h5(tags$li("In step 1 you select a city by pressing the button. The selected city is shown on a map.")),
          h5(tags$li("In step 2 you repeatedly guesses the rank of the selected city until you got it right.")),
          h5(tags$li("When anwsered wrong the actual city that had the selected rank is shown on the map as well.")),
          h5(tags$li("Also the number of residents of the city with the selected rank is shown, so you can deduct if the city has a higher or lower rank than the selected city.")),
          h5(tags$li("If you select the right rank, the game is over."))), br(),
        h3("Click on the button to your left to start the game. Have fun!")),
      conditionalPanel(
        # Only show the panel when a city is selected
        condition = "input.newcity > 0",
        # Make the map high enough to show The Netherlands complete and in high enough resolution
        leafletOutput("map", height = 840)
      )
    )
  )
))
