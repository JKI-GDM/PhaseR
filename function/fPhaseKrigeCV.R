#-----------------------------------------------------------------------------------------------------
print("Calculation of phase- and year-specific Krige accuracy metrics")
#-----------------------------------------------------------------------------------------------------
fPhaseKrigeCV <- function(DEM.DIR,
                          DEM.GRID,
                          DEM.EPSG,
                          TEMP.PHENO.DOY,
                          PLANT,
                          PHASE,
                          YEAR,
                          OUT.DIR,
                          F.STD){
  
  ###Import phenologcial station
  temps.int.pheno <- TEMP.PHENO.DOY
  
  ###Import DEM
  dem.grid <- raster(file.path(DEM.DIR,DEM.GRID))
  names(dem.grid)[1] <- "DEM"
  
  ###Convert to grid to SpatialPixelsDataFrame
  dem.grid <- as(dem.grid, 'SpatialPixelsDataFrame')
  
  ###Reproject phenological stations accordng to grids projection 
  crs(dem.grid) <- paste('+init=epsg:',DEM.EPSG,sep="")
  temps.int.pheno = spTransform(temps.int.pheno, crs(dem.grid))
  
  ###Relate phenological stations to grid values 
  temps.int.pheno@data <- cbind(temps.int.pheno@data,over(temps.int.pheno,dem.grid))
  
  ###Variogram generation
  variogram = autofitVariogram(DOY_PHASE~DEM, 
                               input_data =  temps.int.pheno)
  
  
  ###Cross validation
  print("Autokrige cross validation")
  result.cv <- autoKrige.cv(DOY_PHASE~DEM, temps.int.pheno)
  
  ###Sample number
  sample.number <- data.frame(summary.result.cv.=nrow( temps.int.pheno))
  phase <- data.frame(summary.result.cv.=PHASE)
  plant <- data.frame(summary.result.cv.=PLANT)
  year <- data.frame(summary.result.cv.=YEAR)
  filter <- data.frame(summary.result.cv.=F.STD)
  cv <- data.frame(summary(result.cv))
  cv <- rbind(cv,plant)
  cv <- rbind(cv,phase)
  cv <- rbind(cv,sample.number)
  cv <- rbind(cv,filter)
  cv <- rbind(cv,year)
  cv <- data.frame(unlist(cv))[c(3,4,6,8,12,13,14,15,16),]
  cv <- data.frame(V=cv,AM=c("MAE","MSE","COR","RMSE","PLANT","PHASE","SN","SD","YEAR"))
  
  write.csv2(cv,
             row.names = FALSE,
             paste(OUT.DIR,'CV_',PLANT,"-",PHASE,"_",YEAR,"_FSTD",F.STD,".csv",sep=""))
  
  #saveRDS(variogram,paste(W.DIR,OUT.DIR,'V_',PLANT,"-",PHASE,"_",YEAR,"_FSTD",F.STD,".rds",sep=""))
  return(cv)
  }
