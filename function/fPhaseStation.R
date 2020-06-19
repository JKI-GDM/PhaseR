#-----------------------------------------------------------------------------------------------------
print("Coupling of year- and phase-specific observations and phenological stations")
#-----------------------------------------------------------------------------------------------------
fPhaseStation <- function(PHENO.OBS,
                          IN.DIR,
                          PHENO.STATIONS,
                          PHASE,
                          PLANT,
                          YEAR,
                          start.Phase="10",
                          start.Day=1,
                          OUTRM=F){
  print("Creating SpatialPoints from pheno data")
  ###Result of function "get.pheno.observations.R"
  pheno <- PHENO.OBS
  nrow(pheno)
  ###Import phenological stations 
  stations <- shapefile(file.path(IN.DIR,PHENO.STATIONS))
  ### Target phase and start phase for summation (default: Sowing)
  pheno$STATION <- as.numeric(pheno$STATION)
  pheno <- pheno[which(pheno$PHASE == (PHASE) | pheno$PHASE == start.Phase),]
  ##Check Winter crop?
  if(is.element(PLANT,c(202,203,204,205)) & !is.element(PHASE, c(12,14))){wc <- T}else{wc<-F}
  print(paste("Start DOY in previous year ->", wc))
  if(wc==T){
  ### Set start date in  previous year
  pheno_start <- pheno[which(pheno$PHASE == start.Phase & pheno$YEAR == YEAR-1),]
  }else{
    ### Set start date in current year
    if(!is.element(start.Phase,pheno$PHASE)){
      pheno_start <- pheno
      pheno_start$DOY <- start.Day
    }else{
      pheno_start <- pheno[which(pheno$PHASE == start.Phase & pheno$YEAR == YEAR),]}}
  
  head(pheno_start)
  colnames(pheno_start)[8] <- 'DOY_start'
  ### Set with target phase (YEAR)
  pheno <- pheno[which(pheno$PHASE == PHASE & pheno$YEAR == YEAR),]
  pheno <- pheno[which(pheno$YEAR == YEAR),]
  nrow(pheno)
  
  ## Removal of outliers (1.5 STDVs interval)
  if(OUTRM==T){
    sd <- sd(pheno$DOY, na.rm=T)
    mn <- mean(pheno$DOY, na.rm=T)
    
    pheno <- pheno[which(pheno$DOY < mn+1.5*sd),]
    pheno <- pheno[which(pheno$DOY > mn-1.5*sd),]
    }

  ### Keep only stations with start and observation date
  pheno_start <- pheno_start[(match(pheno$STATION, pheno_start$STATION, nomatch=0)),]
  pheno <- pheno[(match(pheno$STATION, pheno_start$STATION, nomatch=0)),]
  nrow(pheno)
  ### Remove duplicates
  pheno <- pheno[which(duplicated(pheno$STATION) == F),]
  pheno_start <- pheno_start[which(duplicated(pheno_start$STATION) == F),]
  stations <- remove.duplicates(stations)
  nrow(stations@data)
  ### Merging
  stations <- sp::merge(stations,pheno,by="STATION",all.x=F)
  stations <- merge(stations,pheno_start[,c('STATION','DOY_start')],by="STATION",all.x=F)
  ###for phase 10 of summer crops: reset Jultag_start to 0
  if(is.element(PLANT,c(207,208,209,215,231,232,233,234,250,252,253)) & is.element(PHASE, c(10))){
        stations$Jultag_start <- 1}
  head(stations)
  nrow(stations)
  return(stations)
}
