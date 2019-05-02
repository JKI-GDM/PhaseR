### Add new phenology data set
fDownloadPhenObs <- function(PLANT, 
                               URL,
                               annual=T,
                               IN.DIR,
                               OUT.DIR,
                               replace=T){
print("Downloading phenological observations from CDC server...")
  #### Assigning plant_id to name, if provided
  if(class(PLANT) == 'character'){
    if(!is.na(as.numeric(PLANT))) PLANT <- as.numeric(PLANT)
    if(is.na(as.numeric(plant))) PLANT <- convert.PlantID(Plant_Name = PLANT)
  }
  
  ### specifying set: immediate or annual reporters
  if(annual==T){
    ftp.file <- paste(URL, "annual_reporters/",sep="")
    out.file <- paste(W.DIR,OUT.DIR,PLANT,"_annual.txt",sep="")
  }
  if(annual==F){
    ftp.file <- paste(URL, "immediate_reporters/",sep="")
    out.file <- paste(W.DIR,OUT.DIR,PLANT,"_immediate.txt",sep="")
  }
  
    ### determine subdirectory
    plantnames <- read.table(paste(W.DIR,IN.DIR,"PlantNames.txt",sep=""),header=T,sep=',')
    ftp.file <- paste(ftp.file,plantnames$group[which(plantnames$pflanzen_id == PLANT)],'/',sep='')
    
    ### specifying set: recent or historical observations
    ftp.file_recent <- paste(ftp.file, 'recent/',sep='')
    ftp.file_historical <- paste(ftp.file, 'historical/',sep='')
    
    ### Finding data set that fits to plant 
    observations_r <- fread(getURLContent(ftp.file_recent), skip=1,stringsAsFactors = F)$V9
    observations_r <- observations_r[which(str_count(observations_r,pattern=paste(as.character(plantnames$workspace[which(plantnames$pflanzen_id == PLANT)]),'_akt',sep='')) == 1)]
    
    observations_h <- fread(getURLContent(ftp.file_historical), skip=1,stringsAsFactors = F)$V9
    observations_h <- observations_h[which(str_count(observations_h,pattern=paste(as.character(plantnames$workspace[which(plantnames$pflanzen_id == PLANT)]),'_\\d',sep='')) == 1)]
    
    ### Final FTP directory
    ftp.file_recent <- paste(ftp.file_recent,observations_r,sep='')
    ftp.file_historical <- paste(ftp.file_historical,observations_h,sep='')
    ###import historical and recent data set  
    if(length(observations_h > 0)){pheno.obs_h <- read.table(ftp.file_historical, stringsAsFactors = F, sep=";", header=T)}else{pheno.obs_h <- NULL}
    if(length(observations_r > 0) & PLANT!=133){pheno.obs_r <- read.table(ftp.file_recent, stringsAsFactors = F, sep=";",header=T)}else{pheno.obs_r <- NULL}
    ###combine historical and recent data set
    pheno.obs <-  rbind(pheno.obs_h, pheno.obs_r)
    if(!is.null(pheno.obs)){
      pheno.obs <- data.frame(Qualitetsniveau=pheno.obs$Qualitaetsniveau,
                              STATION_ID=pheno.obs$Stations_id,
                              Referenzjahr=pheno.obs$Referenzjahr,
                              Objekt_id.Pflanze=pheno.obs$Objekt_id,
                              Phase_id.Phase=pheno.obs$Phase_id,
                              Eintrittsdatum=pheno.obs$Eintrittsdatum,
                              Eintrittsdatum_QB=pheno.obs$Eintrittsdatum_QB,
                              Jultag=pheno.obs$Jultag)
      
      pheno.obs <- pheno.obs[!duplicated.data.frame(pheno.obs),]
      write.table(pheno.obs, out.file,sep=';',row.names = F,col.names = T)
    }
    cat('...done')
}

