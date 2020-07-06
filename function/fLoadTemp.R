#-----------------------------------------------------------------------------------------------------
print("Load interpolated climate data for a specific vegetation period")
#-----------------------------------------------------------------------------------------------------
fLoadTemp <- function(PHASE.STATION,
                      IN.DIR,
                      PARAMETER){
  
  ###Load result from function "fPhaseStation"
  pheno <- PHASE.STATION
  
  ### Load temperature data for year of harvest
  gridded.parameter <- read.table(paste(IN.DIR,PARAMETER,YEAR,".csv",sep=""),
                                  header = FALSE,
                                  sep = ",",
                                  dec = ".")
  colnames(gridded.parameter) <- c("GRID_ID",paste("T",1:(length(gridded.parameter)-1),sep=""))
  head(gridded.parameter)
  
  ### If winter crops = TRUE -> Load temperature data for the year of sowing
  if(is.element(unique(pheno$PLANT),c(202,203,204,205)) & !is.element(unique(pheno$PHASE),c(12,14))){
    pheno <- pheno[which(pheno$DOY_start > pheno$DOY),]
    ### Earliest start date
    l <- min(pheno$DOY_start,na.rm=T)
    ## temporary data.frame for Referenzjahr
    gridded.a <- gridded.parameter
    
    ## Load previous year temperatures
    gridded.parameter <- read.table(paste(IN.DIR,PARAMETER,(YEAR-1),".csv",sep=""),
                                    header = FALSE,
                                    sep = ",",
                                    dec = ".")
    ### Convert names to negative DOY
    colnames(gridded.parameter) <- c("GRID_ID",paste("T-",(length(gridded.parameter)-2):1,sep=""),paste("T0"))
    ### temporary data.frame for start year
    gridded.b <- gridded.parameter
    ### Create combined data.frame
    gridded.full <-  gridded.a
    rm(gridded.a)
    gc()
    ### combine temperatures from DOY200 of sowing year with target years" temperatures
    gridded.full <- cbind(gridded.full[c(1)],
                          gridded.b[,which(names(gridded.b)==paste("T",-366+l,sep="")):ncol(gridded.b)],
                          gridded.full[,2:ncol(gridded.full)])
    
    
  }else{gridded.full <- gridded.parameter}
  return(gridded.full)
}
