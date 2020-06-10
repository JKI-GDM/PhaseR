#-----------------------------------------------------------------------------------------------------
print("Import phenological observations as result from the function fDownloadPhenObs()")
#-----------------------------------------------------------------------------------------------------
fImportPhenObs <- function(W.DIR,
                           IN.DIR,
                           PLANT,
                           annual=T){
  
  print('Loading phenological observations from disk')
  ### Load local file
  if(annual==F){pheno.obs <- fread(paste(W.DIR,IN.DIR,PLANT,'_immediate.txt',sep=''), stringsAsFactors = F,data.table = F)}
  if(annual==T){pheno.obs <- fread(paste(W.DIR,IN.DIR,PLANT,'_annual.txt',sep=''), stringsAsFactors = F,data.table = F)}
  pheno.obs <- na.omit(pheno.obs)
  
  print('Summary plot of all observed years')
  setwd(file.path(W.DIR,IN.DIR))
  if(annual==T){png(paste("AnnualObservationsYears_",PLANT,c(".png"),sep=""),
      width=2000,height=2000,res=300)}
  if(annual==F){png(paste("ActualObservationsYears_",PLANT,c(".png"),sep=""),
      width=2000,height=2000,res=300)}
  #Plotting
  plot(pheno.obs$Referenzjahr,pheno.obs$Phase_id.Phase,
       main=paste("PLANT ID",unique(pheno.obs$Objekt_id.Pflanze)),
       xaxt="n",
       yaxt="n",
       ylab="PHASE ID",
       xlab="YEAR")
  #axis
  x1 <- seq(min(as.integer(names(split(pheno.obs,pheno.obs$Referenzjahr)))),
           max(as.integer(names(split(pheno.obs,pheno.obs$Referenzjahr)))),
           1)
  x2 <- seq(min(as.integer(names(split(pheno.obs,pheno.obs$Referenzjahr)))),
           max(as.integer(names(split(pheno.obs,pheno.obs$Referenzjahr)))),
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
