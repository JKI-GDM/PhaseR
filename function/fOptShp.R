#-----------------------------------------------------------------------------------------------------
print("Extract best filtered observation variant")
#-----------------------------------------------------------------------------------------------------
fOptShp <- function(SHP.DIR,
                      OPT.DIR,
                      OUT.DIR,
                      PLANT,
                      PHASE){

###Import phenologcial station
files.shp <- read.csv2(paste(OPT.DIR,"OPT-MAX_",PLANT,"-",PHASE,".csv",sep=""))

for(i in 1:nrow(files.shp)){
  setwd(SHP.DIR)
  temps.int.pheno <- st_read(paste("DOY_",files.shp$PLANT[i],"-",files.shp$PHASE[i],"_",files.shp$YEAR[i],"_FSTD",files.shp$STD[i]*10,".shp",sep=""))
  #Export optimal shapefile
  setwd(OPT.DIR)
  st_write(temps.int.pheno,
           paste("DOY_",files.shp$PLANT[i],"-",files.shp$PHASE[i],"_",files.shp$YEAR[i],".shp",sep=""),
           delete_layer = TRUE)
}
}