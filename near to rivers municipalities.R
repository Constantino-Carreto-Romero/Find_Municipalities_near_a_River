########### Find municipalities near rivers ###################

#clean working directory
rm(list = ls())


#################### install & load libraries 

#install
install.packages("ggplot2") #create plots
install.packages("dplyr") #manage data
install.packages("sp") 
install.packages("sf")#spatial analysis
install.packages("rgdal") #load spatial objects
install.packages("tmap") #create maps

# Libraries
library(ggplot2)
library(dplyr)
library(sp)
library(sf)
library(rgdal)
library(tmap)

############## directories 

#project directory
directory="C:/Users/tino_/Dropbox/PC/Documents/proyectos_R/near_to_rivers_municipalities/"
#shape file of rivers
shape_rivers=paste0(directory,"Rios_principales_2021/")
#shape file of municipalities
shape_muns=paste0(directory,"shapefile_mx_municipios/")
#shape file of states
shape_ent=paste0(directory,"shapefile_mx_estados/")

######## prepare the shapefiles

#load shape of rivers
rivers <- readOGR(dsn=paste0(shape_rivers, "Rios_principales_2021.shp"), layer="Rios_principales_2021", stringsAsFactors=F)
#load shape of municipalities
muns <- readOGR(dsn=paste0(shape_muns, "muni_2018gw.shp"), layer="muni_2018gw", stringsAsFactors=F)
#load shape of states
edos <- readOGR(dsn=paste0(shape_ent, "marcogeoestatal2015_gw.shp"), layer="marcogeoestatal2015_gw", stringsAsFactors=F)

# transform to a sf object (so we can use sf functions)
muns_sf<-st_as_sf(muns)
plot(muns_sf$geometry)
rivers_sf<-st_as_sf(rivers)
edos_sf<-st_as_sf(edos)

# define the CRS (coordinate reference system). Must be the same for all shapes
# see: https://en.wikipedia.org/wiki/Spatial_reference_system
muns_sf <- st_transform(muns_sf, crs = 4326)
st_crs(muns_sf)
rivers_sf <- st_transform(rivers_sf, crs = 4326)
st_crs(rivers_sf)
edos_sf <- st_transform(edos_sf, crs = 4326)

############ spatial analysis ##########################

#compute municipalities' centroids 
centroids <- st_centroid(muns_sf)
plot(centroids$geometry)

#map of municipalities
map1<-tm_shape(muns_sf)+
  tm_borders(col="brown", lwd=0.1, alpha=0.3)+
  tm_shape(edos_sf)+
  tm_borders(lwd=1.5)
map1
tmap_save(filename=paste0(directory, "municipalities.png"))

#map of centroids
map2<-tm_shape(centroids)+
  tm_dots(col="brown",alpha=0.5)+
  tm_shape(edos_sf)+
  tm_borders(lwd=1.5)
map2
tmap_save(filename=paste0(directory, "centroids.png"))

#map of rivers
map3<-  tm_shape(edos_sf)+
  tm_borders(lty="dotted" , lwd=1.5)+
  tm_shape(rivers_sf)+
  tm_lines(col="#5D9BFF", lwd=2)
map3
tmap_save(filename=paste0(directory, "rivers.png"))

#create buffer for the rivers: distance from the river
#visually, the rivers become thicker, 10 km to the left and 10km to the right
#distance is assumed in decimal degrees
#to get a distance of 10 km, use a value of 0.09
#see: http://wiki.gis.com/wiki/index.php/Decimal_degrees
rivers_buf <- st_buffer(rivers_sf, dist = 0.09) #aprox 10 km

#map of the buffers
map4<-tm_shape(edos_sf)+
  tm_borders(lty="dotted" , lwd=1.5)+
  tm_shape(rivers_buf)+
  tm_polygons(col="#5D9BFF")
map4
tmap_save(filename=paste0(directory, "rivers_buffer10.png"))

#### buffer contains centroids: check municipalities whose centroid falls 
#inside the buffers
muns_inters_rivers <- st_intersects(centroids,rivers_buf) #arroja una matriz
class(muns_inters_rivers)
muns_inters_rivers 
dim(muns_inters_rivers) #2463, 51

#empty varaible to fill: 1 if it is 10km or less to a river
muns_sf$rivers<-0


for (i in 1:dim(muns_inters_rivers)[1]){
  inter <- muns_inters_rivers[[i]]
  inter<-as.numeric(inter)
  #number of rivers 
  inter<-length(inter)
  
  muns_sf$rivers[i] <-inter
}
muns_sf$rivers[muns_sf$rivers>0]<-1

#map of municipalities near a river
map5<- tm_shape(edos_sf)+
  tm_borders(lty="dotted")+
  tm_shape(muns_sf[muns_sf$rivers>0,])+
  tm_borders(col="brown", alpha=0.5)+
  tm_shape(rivers_sf)+
  tm_lines(col="#5D9BFF", lwd=2)+
  tm_legend(show=FALSE)
map5
tmap_save(filename=paste0(directory, "municipalities_and_rivers.png"))

#map of municipalities near a river (close-up to Chiapas)
mun_p<-"07"
map6<- tm_shape(muns_sf[muns_sf$CVE_ENT==mun_p,])+
  tm_borders(alpha=0.5)+
  tm_shape(muns_sf[muns_sf$CVE_ENT==mun_p & muns_sf$rivers>0,])+
  tm_borders(col="brown", alpha=0.8)+
  tm_fill(col="#E59866")+
  #centroids
  tm_shape(centroids[centroids$CVE_ENT==mun_p & muns_sf$rivers>0,])+
  tm_dots(col="brown")+
  #rivers
  tm_shape(rivers_sf)+
  tm_lines(col="#5D9BFF", lwd=2)+
  #state
  tm_shape(edos_sf[edos_sf$CVE_ENT==mun_p,])+
  tm_borders(lwd=2)+
  tm_legend(show=FALSE)
map6
tmap_save(filename=paste0(directory, "municipalities_and_rivers_chiapas.png"))

