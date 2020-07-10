#-----------------------------------------------------------------------------------------------------
print("Coupling of year- and phase-specific observations and phenological stations")
#-----------------------------------------------------------------------------------------------------
fPhaseStation <- function(PHENO.OBS,
                          IN.DIR,
                          PHENO.STATIONS,
                          PHASE,
                          PLANT,
                          YEAR,
                          start.Phase=10,
                          start.Day=1,
                          OL.RM=T,
                          F.STD2=1.5){
  
  print('Creating SpatialPoints from pheno data')
  ###Result of function "fImportPhenObs.R"
  pheno <- PHENO.OBS
  nrow(pheno)
  
  ###Import phenological stations 
  stations <- shapefile(file.path(IN.DIR,PHENO.STATIONS))
  
  ### Target phase and start phase for summation (default: Sowing)
  pheno$STATION <- as.numeric(pheno$STATION)
  pheno <- pheno[which(pheno$PHASE == (PHASE) | pheno$PHASE == start.Phase),]
  
  ### Determine start DOY
  if(is.element(PLANT,c(202,203,204,205)) & !is.element(PHASE, c(12,14))){WC<-T}else{WC<-F}
  print(paste("Start DOY in previous year ->", WC))
  if(WC==T){
  
  ### Set start date in  previous year
  pheno_start <- pheno[which(pheno$PHASE == start.Phase & pheno$YEAR == YEAR-1),]
  }else{
    ### Set start date in current year
    if(!is.element(start.Phase,pheno$PHASE)){
      pheno_start <- pheno
      pheno_start$DOY <- start.Day
    }else{
      pheno_start <- pheno[which(pheno$PHASE == start.Phase & pheno$YEAR == YEAR),]}}
  colnames(pheno_start)[8] <- 'DOY_start'
  
  ### Set with target phase (YEAR)
  pheno <- pheno[which(pheno$PHASE == PHASE & pheno$YEAR == YEAR),]
  pheno <- pheno[which(pheno$YEAR == YEAR),]
  
  ### Removal of outliers (IV STDVs interval)
  if(OL.RM==T){
    sd <- sd(pheno$DOY, na.rm=T)
    mn <- mean(pheno$DOY, na.rm=T)
    pheno <- pheno[which(pheno$DOY < mn+F.STD2*sd),]
    pheno <- pheno[which(pheno$DOY > mn-F.STD2*sd),]
    }

  ### Keep only stations with start and observation date
  pheno_start <- pheno_start[(match(pheno$STATION, pheno_start$STATION, nomatch=0)),]
  pheno <- pheno[(match(pheno$STATION, pheno_start$STATION, nomatch=0)),]
  
  ### Remove duplicates
  pheno <- pheno[which(duplicated(pheno$STATION) == F),]
  pheno_start <- pheno_start[which(duplicated(pheno_start$STATION) == F),]
  stations <- remove.duplicates(stations)
  
  ### Merging
  stations <- sp::merge(stations,pheno,by="STATION",all.x=F)
  stations <- merge(stations,pheno_start[,c('STATION','DOY_start')],by="STATION",all.x=F)
  
  ### If Phase= 10 & summer crops: reset Jultag_start to 1
  if(is.element(PLANT,c(207,208,209,215,231,232,233,234,250,252,253)) & is.element(PHASE, c(10))){
        stations$Jultag_start <- 1}
  head(stations)
  return(stations)
}
