#-----------------------------------------------------------------------------------------------------
print("Interpolation of filtered phenological observations")
#-----------------------------------------------------------------------------------------------------
fPhaseInterpolation <- function(DEM.DIR,
                                PLANT,
                                SHP.DIR,
                                PHASE.SHP,
                                DEM.GRID,
                                OUT.DIR,
                                CNAME,
                                KRIGE=TRUE){
  ###Import DEM
  dem.grid <- raster(file.path(DEM.DIR,DEM.GRID))
  names(dem.grid)[1] <- "DEM"
  
  ###Import filtered phenologcial station files
  files.shp <- read.csv2(paste(SHP.DIR,"OPT_",PLANT,"-",PHASE,".csv",sep=""))
  
  for(i in 1:nrow(files.shp)){
    setwd(SHP.DIR)  
    temps.int.pheno <- shapefile(paste("DOY_",files.shp$PLANT[i],"-",files.shp$PHASE[i],"_",files.shp$YEAR[i],"_FILTER",files.shp$SD[i],".shp",sep=""))
    
    ##Export optimal shapefile
    setwd(OUT.DIR)
    shapefile(temps.int.pheno,paste("DOY_",files.shp$PLANT[i],"-",files.shp$PHASE[i],"_",files.shp$YEAR[i],".shp",sep=""),overwrite=T)
    
    ##Convert to grid to SpatialPixelsDataFrame
    dem.grid <- as(dem.grid, 'SpatialPixelsDataFrame')
    
    ##Reproject phenological stations accordng to grids projection
    temps.int.pheno = spTransform(temps.int.pheno, crs(dem.grid))
    
    ##Relate phenological stations to grid values 
    temps.int.pheno@data <- cbind(temps.int.pheno@data,over(temps.int.pheno,dem.grid))
    
    print("Interpolating DOY")
    if(KRIGE==TRUE){
      print("KRIGE interpolation")
      result <- autoKrige(as.formula(DOY_PHA ~ 1 + DEM), 
                          input_data =  temps.int.pheno,
                          new_data = dem.grid,
                          verbose=T, 
                          debug.level=-1,
                          nmax=Inf)
      
      print("Export KRIGE results")
      setwd(OUT.DIR)
      writeRaster(raster(result[[1]]), paste("DOY_",files.shp$PLANT[i],"-",files.shp$PHASE[i],"_",files.shp$YEAR[i],".tif",sep=""),overwrite=T)
      writeRaster(raster(result[[1]][3]), paste("KSV_",files.shp$PLANT[i],"-",files.shp$PHASE[i],"_",files.shp$YEAR[i],".tif",sep=""),overwrite=T)
      plot(result[[1]])
    }
    
    if(KRIGE==FALSE){
      xy <- coordinates(temps.int.pheno)
      v <- temps.int.pheno$DOY_PHA
      
      ## pixel plot of spatial data
      #quilt.plot(x,y)
      
      ## fits a GCV thin plate smoothing spline surface to observations.
      r <- raster(dem.grid)
      z <- extract(r, xy)
      ## add as another independent variable
      xyz <- cbind(xy, z)
      fit <- Tps(xyz, v)
      result <- interpolate(r, fit, xyOnly=FALSE)
      resultSE <- interpolate(r, fit, xyOnly=FALSE,fun=predictSE)
      result <- mask(result, r)
      result.SE <- mask(resultSE, r)
      
      print("Export SPLINE results")
      setwd(OUT.DIR)
      writeRaster(result, paste("DOY_",files.shp$PLANT[i],"-",files.shp$PHASE[i],"_",files.shp$YEAR[i],".tif",sep=""),overwrite=T)
      writeRaster(resultSE, paste("SE_",files.shp$PLANT[i],"-",files.shp$PHASE[i],"_",files.shp$YEAR[i],".tif",sep=""),overwrite=T)
  }
  }
}
