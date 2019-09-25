
#############################################
#   Data Scietifique Workshops              #
#   Introduction to Spatial Data in R       #
#   Instructor: Yara Abu Awad               #
#############################################


# In this workshop we will:
# Import addresses and geocode them
# Plot addresses
# Create buffers around addresses

## SET WORKING DIRECTORY
### Go to Session->Set Working Directory->Choose Directory
### or use setwd() function


## INSTALL PACKAGE PHOTON FROM GITHUB AND LOAD LIBRARY
### devtools::install_github(repo = 'rCarto/photon')
library(photon)

## IMPORT .CSV FILE WITH ADDRESSES
addresses <- read.csv('example_addresses.csv', header = T, stringsAsFactors = FALSE)

## DETERMINE LONGITUDE AND LATITUDE OF ADDRESSES
### below code is adopted from: https://github.com/rCarto/photon
place <- geocode(addresses$address, limit = 1, key = "place")

## ADD LONGITUDE AND LATITUDE TO ORIGINAL DATASET 'addresses'

addresses$Latitude = place$lat
addresses$Longitude = place$lon

## CONVERT TO A SHAPEFILE
library(sp)
coordinates(addresses)<-~Longitude+Latitude 
proj4string(addresses) = CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs") 
plot(addresses)


## PLOT ADDRESSES ON MAP OF CANADA
### OPTION 1: DOWNLOAD SHAPEFILE OF CANADA FROM https://www12.statcan.gc.ca/census-recensement/2011/geo/bound-limit/bound-limit-2011-eng.cfm
############  IMPORT SHAPEFILE

library(sf)
canada = st_read('gpr_000b11a_e/gpr_000b11a_e.shp')
st_crs(canada) #check the coordinate system
summary(canada) #look at attribute table
unique(canada$PRFNAME) #attribute table behaves like a data frame!

library(magrittr)
plot(canada[canada$PRFNAME == 'Qu\xe9bec'] %>% st_geometry)
addr.sf = st_as_sf(addresses)
plot(addr.sf%>% st_geometry,col = "red", add = TRUE )


### OPTION 2: RETRIEVE SHAPEFILE FROM RASTER LIBRARY

library(raster)
canada <- getData('GADM', country="CAN", level=2)
summary(canada)
table(canada$NAME_1)

QC <- canada[canada$NAME_1 == 'Québec',]

rm(canada)

library(rgeos)
QC <- gSimplify(QC, tol=0.01, topologyPreserve=TRUE)
plot(QC)
plot(addresses, col = "red", add = TRUE)


## PROJECT ADDRESSES SO WE CAN DRAW A BUFFER
addresses = spTransform(addresses, CRS("+init=epsg:5070"))

## CONVERT TO SF
library(sf)
addr.sf = st_as_sf(addresses)

## DRAW 10 KM BUFFER AROUND EACH POINT
buffers = st_buffer(addr.sf, dist = 500)

## plot
library(magrittr)

plot(buffers%>% st_geometry)
plot(addr.sf%>% st_geometry,col = "red", add = TRUE )
