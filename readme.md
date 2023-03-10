# Find municipalities within some distance from a river

Constantino Carreto Dec 26, 2022

In this project, I use spatial-analysis techniques to find the municipalities whose centroid is 10 km or less from a river, in Mexico. This could be of interest if, for instance, we want to find the municipalities that could be affected the most by floods or exposed to diseases transmitted by mosquitoes. I try to exemplify some spatial techniques and the previous data preparation to be able to implement this spatial analysis. This example can be easily extended to other spatial techniques. I use only a pair of functions of the [sf](https://r-spatial.github.io/sf/) package, but this package has many available functions. 

First, I compute municipalities' centroids:

<img src="./centroids.png"
     alt="Markdown Monster icon"
     style="float: left; margin-right: 5px;"
     width="600" height="400" />
     
 On the other hand, in the case of the rivers, this is what a simple map looks like:
 <img src="./rivers.png"
     alt="Markdown Monster icon"
     style="float: left; margin-right: 5px;"
     width="600" height="400" />


Then, I compute a buffer of 10 km for the rivers in Mexico, that is, I make the rivers "thicker" by 10 km to the left and 10 km to the right:

<img src="./rivers_buffer10.png"
     alt="Markdown Monster icon"
     style="float: left; margin-right: 5px;"
     width="600" height="400" />

Finally, I localize the municipalities whose centroid is within 10 km or less from a river. I do this by a spatial intersection between the centroids and the rivers' buffers:

<img src="./municipalities_and_rivers.png"
     alt="Markdown Monster icon"
     style="float: left; margin-right: 5px;"
     width="600" height="400" />

This is a close-up of the state of Chiapas:

<img src="./municipalities_and_rivers_chiapas.png"
     alt="Markdown Monster icon"
     style="float: left; margin-right: 5px;"
     width="600" height="400" />

To find the municipalities that are crossed by a river I could have simply intersected the municipalities' polygons and the rivers' buffers, but I added the centroid component to exemplify its computation. Besides, by using the centroids, we could guarantee that the rivers' buffers crossed a great proportion of the municipality, just in case we are interested in finding municipalities with greater exposition to the rivers.
