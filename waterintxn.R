## clear workspace

rm(list = ls())
gc()


##retreive taskid
taskid = as.numeric(Sys.getenv("SLURM_ARRAY_TASK_ID"))

## check if id already ran

files = Sys.glob('gisvars/water_*.rds')
target = paste0('water_',taskid,'.rds')

##
if(!target %in%files){
library(sf)
library(tibble)
}
print(taskid)

## load one piece 

piece = st_read(paste0('/n/scratchlfs/shared/yara/maparcels/piece_',taskid,'.shp'))

## create list of all unique ids to merge back to

odat = as.data.frame(piece$OBJECTI)
names(odat) = 'OBJECTI'

water = st_read('/n/regal/schwartz_lab/yara/shapefiles/_waterbodies.shp')
water = st_zm(water)

## make sure coordinate systems match
piece = st_transform(piece, st_crs(water))
buffer = st_buffer(piece, dist = 2000)

#intersect

intxn = st_intersection(buffer, water)

#calculate area

intxn = as_tibble(intxn)
intxn$areaWater2k = st_area(intxn$geometry)

##### extract data
intxn$areaWater2k = as.numeric(intxn$areaWater2k)
intxn = subset(intxn, select = c(OBJECTI, areaWater2k))
odat = merge(odat, intxn, all.x = T, by = 'OBJECTI')
rm(intxn, buffer)

## 10km
buffer = st_buffer(piece, dist = 10000)
intxn = st_intersection(buffer, water)
intxn = as_tibble(intxn)
intxn$areaWater10k = st_area(intxn$geometry)
intxn$areaWater10k = as.numeric(intxn$areaWater10k)
intxn = subset(intxn, select = c(OBJECTI, areaWater10k))
odat = merge(odat, intxn, all.x = T, by = 'OBJECTI')

rm(intxn, buffer, water)

saveRDS(odat, file = paste0('/n/scratchlfs/shared/yara/gisvars/water_',taskid,'.rds'))
