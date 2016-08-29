#
#
# server.R, the server file for our shiny app.
# 28/08/2016, Michel de Leeuw, version 1.1
#
# The app is a small game that lets thge user guess the ranking of a randomly choosen Dutch city (top 25).
# In step 1 the user selects a city by pressing the button
# In step 2 the user repeatedly guesses the rank of the city.
# When anwsered wrong the actual city that had the selected rank is shown on the map as well.
# Also the number of residents of the city with the selected rank is shown, so the user knows if the city has a higher or 
# lower rank than selected.
# If users selects the right rank, the game is over.
#
# Note that the app uses session variables. They are initialised in the body of the shinyServer function and updated within some of 
# the reactive functions. Therefore <<-'s (update variables in a higher scope) are used in stead <-'s.
#

library(shiny)
# Leaflet is used for displaying the map
library(leaflet)
# GoogleVis is used of displaying the table of selected ranks
library(googleVis)

# The 25 largest cities of the Netherlands
cities <-
  structure(list(sequence = 1:25, 
                 name = structure(c(4L, 20L, 8L, 22L, 11L, 21L, 13L, 2L, 7L, 19L, 5L, 14L, 12L, 6L, 3L, 23L, 1L, 15L, 25L, 24L, 17L, 18L, 9L, 10L, 16L), 
                                  .Label = c("'s-Hertogenbosch", "Almere", "Amersfoort", "Amsterdam", "Apeldoorn", "Arnhem", "Breda","Den Haag", "Dordrecht", "Ede", "Eindhoven", "Enschede", "Groningen", "Haarlem", "Haarlemmermeer", "Leeuwarden", "Leiden", "Maastricht", "Nijmegen", "Rotterdam", "Tilburg", "Utrecht", "Zaanstad", "Zoetermeer", "Zwolle"), 
                                  class = "factor"), 
                 residents = c(838338L, 631155L,520704L, 339946L, 225020L, 212943L, 200487L, 198823L, 182424L, 172322L, 159249L, 158305L, 157999L, 154497L, 153773L, 152678L, 151752L, 144908L, 125097L, 124399L, 122915L, 122418L, 118496L, 112593L, 108041L), 
                 latitude = c(52.5167747, 51.9244201, 52.0704978, 52.0907374, 51.441642, 51.560596, 53.2193835, 52.3507849, 51.5719149, 51.8125626, 52.211157, 52.3873878, 52.2215372, 51.9851034, 52.1561113, 52.4579659, 51.6978162, 52.3003784, 52.5167747, 52.060669, 52.1601144, 50.8513682, 51.8132979, 52.0401675, 53.2012334), 
                 longitude = c(6.0830219, 4.4777325, 4.3006999, 5.1214201, 5.4697225, 5.0919143, 6.5665018, 5.2647016, 4.768323, 5.8372264, 5.9699231, 4.6462194, 6.8936619, 5.8987296, 5.3878266, 4.7510425, 5.3036748, 4.6743594, 6.0830219, 4.494025, 4.4970097, 5.6909725, 4.6900929, 5.6648594, 5.7999133)), 
            .Names = c("sequence", "name", "residents", "lat", "long"), 
            class = "data.frame", 
            row.names = c(NA, -25L))

# Define server logic required for the game
shinyServer(function(input, output, session) {
  
  #Initialise the session
  selected_city <- list(seq=NA, name="", residents=NA)
  choosen_cities <- data.frame(no=integer(), guess=integer(), correct=character(), city=character(), residents=integer())
  choosen_cities_count <- 0;
  
  # Initiate the selected city. It is updated every time the user hits "Select a city"
  selected_city <- reactive({
    # When the button isn't pushed yet, the selected city remains empty
    if (input$newcity > 0) {
      # Select one of first 25 cities, but not the first one, Amsterdam, that's to easy
      seq <- sample(2:25, 1)
      # reset the guesses table and count
      choosen_cities <<- data.frame(no=integer(), 
                                    guess=integer(), 
                                    correct=character(), 
                                    city=character(), 
                                    residents=integer())
      choosen_cities_count <<- 0
      # Reset the input box by making it empty
      updateTextInput(session, "yourguess", value = NA)  
      # Return then new city
      list(seq=seq, 
           name=cities$name[seq], 
           residents=cities$residents[seq], 
           lat=cities$lat[seq], 
           long=cities$long[seq]
           )
    }
  })

  # Output for the selected city
  output$selected_city <- renderText({
     paste(selected_city()$name, ", ", format(selected_city()$residents, big.mark = ","), " residents", sep = "")
  })
  
  # Reactive function for processing a guess
  process_guess <- reactive({
    if (input$guess>0 & isolate(input$yourguess) > 0) {
      # Increase the count
      choosen_cities_count <<- choosen_cities_count + 1
      # Set correct or not
      if (isolate(input$yourguess)==selected_city()$seq) {correct="Yes"} else {correct="No"}
      # Add the selected rank/city to the dataframe containing all selected ranks/cities
      choosen_cities <<- rbind (choosen_cities, 
                                data.frame(no=choosen_cities_count, 
                                           guess=isolate(input$yourguess), 
                                           correct=correct, 
                                           city=cities[isolate(input$yourguess),]$name, 
                                           residents=cities[isolate(input$yourguess),]$residents))
    }
    # This one is important. By returning the number of times the user pressed the "validate guess" button, it is
    # garanteed that the reactive funtion updates the session variables.
    return(input$guess)
  })
  
  # Outputs for the table of choosen cities, the number of guesses
  output$guess_result <- renderText({
    # React to both validate guess button and new city button. Also to the result of the reactive function process_guess
    input$guess
    input$newcity
    # Show the result depending on having guessed at and having it wrong or right
    x <- process_guess()
    if (choosen_cities_count == 0) {
      ""
    }
    else if (choosen_cities[choosen_cities_count,]$correct=="No") {
      paste("Your guess is wrong. The ",
            as.character(isolate(input$yourguess)),
            "th city of The Netherlands is ",
            cities[isolate(input$yourguess),]$name,
            ". It has ",
            format(cities[isolate(input$yourguess),]$residents, big.mark = ","),
            " residents.",
            sep="")
    } 
    else {
      paste("You got it right! The ",
            as.character(isolate(input$yourguess)),
            "th city of The Netherlands is ",
            cities[isolate(input$yourguess),]$name,
            ". It took you ",
            as.character(choosen_cities_count),
            " turn(s) to find it. Great job!!! Reload the page (F5) to restart the game.",
            sep="")
    }
  })

  # Output the table
  output$choosen_cities_table <- renderGvis({
    # React to both validate guess button and new city button. Also to the result of the reactive function process_guess
    input$guess
    input$newcity
    x <- process_guess()
    # Set some nice headers
    df <- choosen_cities
    names(df) <- c("No.", "Your answer", "Correct", "Actual city", "Residents")
    # Use googleVis
    gvisTable(df)
  })
  
  # Use leaflet to show the map
  output$map <- renderLeaflet({
    # React to both validate guess button and new city button. Also to the result of the reactive function process_guess
    input$guess
    input$newcity
    x <- process_guess()
    map <- leaflet() %>% 
      addProviderTiles("CartoDB.Positron") %>%
      # Set the center of the map to the center of The Netherlands
      setView(5.1214201,
              52.17,
              zoom=8) %>%
      # Show the selected city
      addMarkers(lat=selected_city()$lat, 
                 lng=selected_city()$long,
                 popup=selected_city()$name)
    # Show the city with the selected rank
    if (choosen_cities_count > 0) {
      map <- addMarkers(map,
                        lat=cities[isolate(input$yourguess),]$lat,
                        lng=cities[isolate(input$yourguess),]$long,
                        popup=cities[isolate(input$yourguess),]$name)
    }
    # Plot the map
    map
  })
})
