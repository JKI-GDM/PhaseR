#-----------------------------------------------------------------------------------------------------
print("Import phenological observations as a result from the function fDownloadPhenObs()")
#-----------------------------------------------------------------------------------------------------
fImportPhenObs <- function(OBS.DIR,
                           PLANT,
                           annual=T){
  
  print('Loading phenological observations from disk')
  ### Load local file
  if(annual==F){pheno.obs <- fread(paste(OBS.DIR,PLANT,'_immediate.txt',sep=''), stringsAsFactors = F,data.table = F)}
  if(annual==T){pheno.obs <- fread(paste(OBS.DIR,PLANT,'_annual.txt',sep=''), stringsAsFactors = F,data.table = F)}
  pheno.obs <- na.omit(pheno.obs)
  
  print('Plot available yearly plant- and phase-specific observations')
  setwd(file.path(OBS.DIR))
  if(annual==T){png(paste("AnnualObservationsYears_",PLANT,c(".png"),sep=""),
      width=2000,height=2000,res=300)}
  if(annual==F){png(paste("ActualObservationsYears_",PLANT,c(".png"),sep=""),
      width=2000,height=2000,res=300)}
  plot(pheno.obs$YEAR,pheno.obs$PHASE,
       main=paste("PLANT",unique(pheno.obs$PLANT)),
       xaxt="n",
       yaxt="n",
       ylab="PHASE",
       xlab="YEAR")
  x1 <- seq(min(as.integer(names(split(pheno.obs,pheno.obs$YEAR)))),
           max(as.integer(names(split(pheno.obs,pheno.obs$YEAR)))),
           1)
  x2 <- seq(min(as.integer(names(split(pheno.obs,pheno.obs$YEAR)))),
           max(as.integer(names(split(pheno.obs,pheno.obs$YEAR)))),
           5)
  y1 <- seq(1,67,1)
  y2 <- seq(1,67,5)
  axis(1, at=x1, col.tick="grey", las=2,labels=FALSE,cex=1.2)
  axis(1, at=x2, col.tick="black", las=1,labels=TRUE,cex=1.2)
  axis(2, at=y1, col.tick="grey", labels=FALSE, las=1,cex=1.2)
  axis(2, at=y2, col.tick="black", labels=TRUE, las=1,cex=1.2)
  dev.off()
  return(pheno.obs)
}
