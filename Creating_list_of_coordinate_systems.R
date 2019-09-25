################################################
#   Data Scietifique Workshops                 #
#   Creating a list of coordinate systems      #
#   Instructor: Yara Abu Awad                  #
################################################


library(rgdal)

EPSG <- make_EPSG()
NA1983<- EPSG[grep("NAD83", EPSG$note),]
NA1983<- EPSG[grep("proj=longlat", NA1983$prj4),]
