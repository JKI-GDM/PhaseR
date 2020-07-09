#-----------------------------------------------------------------------------------------------------
print("Calculation of effective temperatures and temperature summation")
#-----------------------------------------------------------------------------------------------------
fTeffSum <- function(TEMP.GRID,
                     PHASE.STATION){
  ### Import interpolated temperatures for a specific reference year (result of function fLoadTtemp)
  temps_int_dem <- TEMP.GRID
  ### Import spatial data frame of stations and phenological observations (result of function fPhaseStation")
  pheno <- PHASE.STATION
  ### Extract PHASE and PLANT
  PLANT <- unique(pheno$PLANT)
  PHASE <- unique(pheno$PHASE)
  ### Selection of base temperature "Tb"
    if(is.element(PLANT, c(202,203,204,207,208,215))){Tb <- 5.5} 
    else if(PLANT == 205) {Tb <- 5.0} 
    else if(PLANT == 201) {Tb <- 2.0}
    else if(PLANT == 201) {Tb <- 2.0}
    else if(PLANT == 209) {Tb <- 6.0}
    else if(PLANT == 250) {Tb <- 3} 
    else if(PLANT == 252) {Tb <- 3} 
    else if(PLANT == 253) {Tb <- 3} 
    else if(PLANT < 200) {Tb <- 0.0} 
    else if(PLANT > 300 & PLANT < 40) {Tb <- 0.0} 
    else if(PLANT > 400) {Tb <- 10}
    else {Tb <- 5}
  ### Base temperature is multiplied by 10 according to DWD temperatures 
  Tb <- Tb*10
  
  ### Removing superflous coloumns
  pheno@data <- data.frame(LON=data.frame(coordinates(spTransform(pheno, CRS("+proj=longlat +datum=WGS84"))))[[c(1)]],
                           LAT=data.frame(coordinates(spTransform(pheno, CRS("+proj=longlat +datum=WGS84"))))[[c(2)]],
                           GRID_ID=pheno@data$GRID_ID,
                           STATION=pheno@data$STATION,
                           ID=seq(1,nrow(pheno),1),
                           YEAR=pheno@data$YEAR,
                           PLANT=pheno@data$PLANT, 
                           PHASE=pheno@data$PHASE,
                           DATE=pheno@data$DATE, 
                           DOY=pheno@data$DOY,
                           DOY_start=pheno@data$DOY_start, 
                           stringsAsFactors = F)
  
  ### Merging of temps_int_dem and pheno
  temps_int_pheno <- merge(pheno,temps_int_dem, by="GRID_ID")
  
  ### Detection of temperature coloums in temps_int_pheno
  col.start <- length(pheno@data)+1
  col.end <- length(temps_int_pheno@data)
  cols2adj <- (col.start:col.end)#
  
  ### Subtraction of base temperature
  head(temps_int_pheno)
  temps_int_pheno@data[,cols2adj] <- temps_int_pheno@data[,cols2adj]-Tb
  
  ### Adjusting for daylength
  daylengths_station <- temps_int_pheno[,cols2adj]
  LATS <- temps_int_pheno$LAT
  
  ### Calculation of daylengths
  for(i in seq(1,ncol(daylengths_station))){
      d <- as.numeric(substr(names(daylengths_station[i]),start=2,stop=5))
      if(d<0){d<-366+d}
      daylengths_station@data[,i] <- geosphere::daylength(LATS,d)
      }

  ### Adjusting temperatures by DL/24
  temps_int_pheno@data[,cols2adj] <- daylengths_station@data/24*temps_int_pheno@data[,cols2adj]

  ### Delete negative temperatures
  temps_int_pheno@data[temps_int_pheno@data<0] <- 0
  ### For winter crops, the daily temperatures between the first day of phase 10 und DOY=36 are assigned. 
  if(is.element(PLANT,c(202,203,204,205)) & (PHASE != 14 & PHASE!=12)){
    temps_int_pheno$DOY_start <- -366+temps_int_pheno$DOY_start
  }
  
  ### Calculating temperature sums
  temps_int_pheno <- temps_int_pheno[which(temps_int_pheno$DOY_start >= as.numeric(substr(names(temps_int_pheno)[col.start],start=2,stop=5))),]
  temps_int_pheno <- temps_int_pheno[which(temps_int_pheno$DOY > temps_int_pheno$DOY_start),]
  t_sums <- temps_int_pheno$DOY_start
  for (i in seq(along=t_sums)) {
    t_sums[i] <- rowSums(temps_int_pheno@data[i,((which(names(temps_int_pheno)==paste("T",temps_int_pheno$DOY_start[i],sep="")))):
                                                which(names(temps_int_pheno)==paste("T",temps_int_pheno$DOY[i],sep=""))])
  }
  
  ### Appending temperature sums to merged data frame
  temps_int_pheno@data$t_sums <- t_sums
  return(temps_int_pheno)
}
