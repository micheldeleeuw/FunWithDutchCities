Having fun with Dutch cities
========================================================
author: Michel de Leeuw
date: 28/08/2016
autosize: true

Background of the project
========================================================
- This presentation is part of the Coursera course - Developing Data Products.
- It the project for the 9th course of the Data Science specialization by the Johns Hopkins University.
- The purpose of the project is to experiment with creating interactive data products with R, R Studio and Shiny.
- You can play the game on http://micheldeleeuw.shinyapps.io/Having_fun_with_Dutch_cities/
- You can look at the code on https://github.com/micheldeleeuw/FunWithDutchCities
- Data gathered from https://nl.wikipedia.org/wiki/Lijst_van_grootste_gemeenten_in_Nederland

Why a (simple) game?
========================================================
- It must be fun to do the peer review.
- Living in The Netherlands I'd like to promote my country. It's beautiful, please consider it for a holiday! <div style="width:400px; height:250px">![Zwolle](zwolle.jpg)</div>This is Zwolle. I live a few hunderd meters from this nice scenary.
- A game is great for experimenting with user interaction.
- Cities can be plotted with shiny and additional libraries, that is both interesting and a good exercise.

Interesting code 1: Maps with Leaflet
========================================================
- The Leaflet package includes powerful and convenient features for integrating with Shiny applications.
- Makes use of open street maps.
- Good documentation, eg. https://rstudio.github.io/leaflet/shiny.html
- Example in app makes use of CartoDB.Positron provider and zoom possibility:


```r
library(leaflet)
map <- leaflet() %>% 
  addProviderTiles("CartoDB.Positron") %>% 
  setView(5.1214201, 52.17, zoom=8)
map
```


Interesting code 2: Scoping with <<-
========================================================
- In the app I made use of session scoped variables. It makes the code less complex.
- They are set in server.R, within the call to shinyServer(), but outside of the individual output functions.
- On update use <<-instead of <-
- Example


```r
a <- 1; b <- 1
f<-function(x) {a <- x + 1; b <<- x + 1}
f(1)
a; b
```

```
[1] 1
```

```
[1] 2
```


