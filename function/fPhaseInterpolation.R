#-----------------------------------------------------------------------------------------------------
print("Interpolation of filtered optimal phenological observations")
#-----------------------------------------------------------------------------------------------------
fPhaseInterpolation <- function(PLANT,
                                PHASE,
                                YEAR,
                                SHP.DIR,
                                SHP.EPSG,
                                DEM.DIR,
                                DEM.GRID,
                                DEM.EPSG,
                                OUT.DIR,
                                KRIGE=TRUE,
                                SPLINE=FALSE,
                                SPACC=FALSE,
                                VALIDATION=TRUE){
  ##Import DEM
  dem.grid <- raster(file.path(DEM.DIR,DEM.GRID))
  proj4string(dem.grid) <- CRS(paste('+init=epsg:',DEM.EPSG,sep=""))
  names(dem.grid)[1] <- "DEM"
  
  ##Import filtered observation shape file 
  setwd(SHP.DIR)
  temps.int.pheno <- st_read(paste("DOY_",PLANT,"-",PHASE,"_",YEAR,".shp",sep=""))
  st_crs(temps.int.pheno) = as.numeric(SHP.EPSG)
  #st_geometry(temps.int.pheno) <- NULL

  
  ##Convert grid to SpatialPixelsDataFrame
  dem.grid <- as(dem.grid, 'SpatialPixelsDataFrame')

  ##Reproject phenological stations according to grids projection
  temps.int.pheno <- st_transform(temps.int.pheno, st_crs(dem.grid))
  names(temps.int.pheno)
  
  ##Relate phenological stations to grid values 
  temps.int.pheno <- cbind(temps.int.pheno,over(as_Spatial(temps.int.pheno),dem.grid))

  
    if(VALIDATION==TRUE){
  ##Splitting data in training and test set using createDataPartition() function from caret
  indxTrain <- createDataPartition(y = temps.int.pheno$DOY,p = 0.75,list = FALSE)
  training <- temps.int.pheno[indxTrain,]
  s <- data.frame(ID=setdiff(as.numeric(temps.int.pheno$ID),as.numeric(training$ID)))
  testing <- merge(temps.int.pheno,s,by="ID")
  
  #Checking distibution in original data and partitioned data
  training <- na.omit(training)
  testing <- na.omit(testing)
  
  #Export
  write_sf(training, paste(OUT.DIR,"TRAIN_",PLANT,"-",PHASE,"_",YEAR,".shp",sep=""), delete_layer = TRUE)
  write_sf(training, paste(OUT.DIR,"TEST_",PLANT,"-",PHASE,"_",YEAR,".shp",sep=""), delete_layer = TRUE)
  }
  
  print("Interpolating DOY")
  if(KRIGE==TRUE){
  print("KRIGE interpolation")
    result <- autoKrige(as.formula(DOY ~ 1 + DEM), 
                        input_data =  as_Spatial(temps.int.pheno),
                        new_data = dem.grid,
                        verbose=T, 
                        debug.level=-1,
                        nmax=Inf)
    
    print("Export KRIGE and validation results")
    setwd(OUT.DIR)
    writeRaster(raster(result[[1]]), paste("DOY_",PLANT,"-",PHASE,"_",YEAR,".tif",sep=""),overwrite=T)
    if(SPACC==TRUE){
    writeRaster(raster(result[[1]][3]), paste("KSV_",PLANT,"-",PHASE,"_",YEAR,".tif",sep=""),overwrite=T)
    }
    #print("Calculate global error metric")
    #GEM <- quantile(raster(result[[1]][3]),na.rm=TRUE)
    #GEM <- data.frame(GEM)
    #colnames(GEM) <- c("KSV")


    if(VALIDATION==TRUE){
      result.acc <- autoKrige(as.formula(DOY ~ 1 + DEM), 
                          input_data =  as_Spatial(training),
                          new_data = dem.grid,
                          verbose=T, 
                          debug.level=-1,
                          nmax=Inf)
      
      ##Convert interpolation result to SpatialPixelsDataFrame
      r <- raster(result.acc[[1]])
      r <- as(r, 'SpatialPixelsDataFrame')

      names(r) <- c("DOY_int")
      
      ##Relate phenological stations to grid values 
      testing <- cbind(testing,over(as_Spatial(testing),r))
      
      ##Accuarcy metrics
      VM <- data.frame(PLANT=0, PHASE=0, YEAR= 0, ON = 0, MSE=0,MAE=0,RMSE=0,R2=0)
      
      VM$PLANT <- PLANT
      VM$PHASE <- PHASE
      VM$YEAR  <- YEAR
      VM$ON    <- nrow(temps.int.pheno)
      VM$RMSE  <- rmse(testing$DOY,testing$DOY_int)
      VM$MAE   <- mae(testing$DOY,testing$DOY_int)
      VM$MSE   <- mse(testing$DOY,testing$DOY_int)
      VM$R2    <- r2(testing$DOY,testing$DOY_int)
      write.csv2(VM, 
                 file=paste("VAM_",PLANT,"-",PHASE,"_",YEAR,".csv",sep=""),
                 row.names = FALSE)
    }
  }
  
  
  
  if(SPLINE==TRUE){
  print("SPLINE interpolation")  
    xyz <- data.frame(as.data.frame(st_coordinates(temps.int.pheno))$X, as.data.frame(st_coordinates(temps.int.pheno))$Y, temps.int.pheno$DEM)
    v <- temps.int.pheno$DOY
    r <- raster(dem.grid)
    fit <- Tps(xyz, v)
    result <- interpolate(r, fit, xyOnly=FALSE)
    result <- mask(result, r)
    plot(result)
    if(SPACC==TRUE){
    resultSE <- interpolate(r, fit, xyOnly=FALSE,fun=predictSE)
    resultSE <- mask(resultSE, r)
    }
      
      
    print("Export SPLINE and validation results")
    setwd(OUT.DIR)
    writeRaster(result, paste("DOY_",PLANT,"-",PHASE,"_",YEAR,".tif",sep=""),overwrite=T)
    if(SPACC==TRUE){
    writeRaster(resultSE, paste("SSE_",PLANT,"-",PHASE,"_",YEAR,".tif",sep=""),overwrite=T)
    print("Calculate global error metric (Standard error )")
    GEM <- quantile(resultSE,na.rm=TRUE)
    GEM <- data.frame(GEM)
    colnames(GEM) <- c("SEE")
    }
    
    if(VALIDATION==TRUE){
      xyz <- data.frame(as.data.frame(st_coordinates(training))$X,
                        as.data.frame(st_coordinates(training))$Y,
                        training$DEM)
      v <- training$DOY
      fit <- Tps(xyz, v)
      result <- interpolate(r, fit, xyOnly=FALSE)
      result <- mask(result, r)
      plot(result)
      ##Convert interpolation result to SpatialPixelsDataFrame
      r <- as(result, 'SpatialPixelsDataFrame')
        
      ##Reproject phenological stations according to grids projection
      names(r) <- c("DOY_int")
        
      ##Relate phenological stations to grid values 
      testing <- cbind(testing,over(as_Spatial(testing),r))
      
      ##Accuarcy metrics
      VM <- data.frame(PLANT=0, PHASE=0, YEAR= 0, ON = 0, MSE=0,MAE=0,RMSE=0,R2=0)
      
      VM$PLANT <- PLANT
      VM$PHASE <- PHASE
      VM$YEAR  <- YEAR
      VM$ON    <- nrow(temps.int.pheno)
      VM$RMSE  <- rmse(testing$DOY,testing$DOY_int)
      VM$MAE   <- mae(testing$DOY,testing$DOY_int)
      VM$MSE   <- mse(testing$DOY,testing$DOY_int)
      VM$R2    <- r2(testing$DOY,testing$DOY_int)
      write.csv2(VM, 
                 file=paste("VAM_",PLANT,"-",PHASE,"_",YEAR,".csv",sep=""),
                 row.names = FALSE)
    }
  }
  if(SPACC==TRUE){
  write.csv2(GEM, 
             file=paste("GEM_",PLANT,"-",PHASE,"_",YEAR,".csv",sep=""))
  }
  }
