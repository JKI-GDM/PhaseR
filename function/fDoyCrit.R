#-----------------------------------------------------------------------------------------------------
print("Determination of optimal quantile (optional) and DOY on which quantile is exceeded")
#-----------------------------------------------------------------------------------------------------
fDoyCrit<-function(TEMP.PHENO,
                   OUT.DIR,
                   OL.RM=T,
                   F.STD=1.5,
                   Q1,
                   Q2){
  
  temps_int_pheno <- TEMP.PHENO
  head(TEMP.PHENO)
  
  ### Cumulative sums from start DOY to maximum DOY
  cumsums <- temps_int_pheno
  for(i in 1:nrow(cumsums)){
    cums2adj <- which(names(cumsums)==paste("T",cumsums$DOY_start[i], sep="")):(which(names(cumsums)=="T_SUMS")-1)
    cumsums@data[i,cums2adj] <- cumsum(as.matrix(cumsums@data[i,cums2adj]))
  }
  
  ### Modelled DOY
  temps_int_pheno@data["DOY_PHASE"] <- 0
  
  ### Optimization
    ME_MIN <- Inf
  
    ## Set up quantiles data frame list and inital value for mean error
    quantiles <- data.frame(Q=seq(from=Q1, to=Q2, by=0.05),R=0,RMSE=0,ME=0)
    
    ## Quantile determination
    total <- nrow(quantiles)
    pq <- txtProgressBar(min=0, max=total, style=3)
    for(q in seq(1,nrow(quantiles))){
      med <- quantile(temps_int_pheno$T_SUMS, quantiles$Q[q],na.rm=TRUE)
      
      ## Selection of first DOY when critical temperature sum is exceeded
      for (i in seq(1,nrow(temps_int_pheno))){
        ## current phenostation
        col <- cumsums[i,(which(names(cumsums)==paste("T",cumsums$DOY_start[i], sep=""))):(which(names(cumsums)=="T_SUMS")-1)]
        
        ## extraction of DOY with cumulative temperatures higher than estimated threshold
        col.names=as.numeric(substr(names(col),start=2,stop=7))
        
        ## selection of first day when threshold is exceeded
        DOY_crit <- min(col.names[which(col@data > med)])
        temps_int_pheno@data$DOY_PHASE[i] <- as.numeric(DOY_crit)
      }
      
      
      ### Appending to temporal temps_int_pheno
      temps_int_pheno_opt <- temps_int_pheno
      
      ### Error filtering (Inf and outliers)
      if(OL.RM==T){
      temps_int_pheno_opt <- temps_int_pheno_opt[which(abs(temps_int_pheno_opt$DOY_PHASE-temps_int_pheno_opt$DOY) <= F.STD*sd(temps_int_pheno_opt$DOY)),]
      }
      
      ### Calculation of statistics
      quantiles$R[q] <- cor(temps_int_pheno_opt@data["DOY"],temps_int_pheno_opt@data["DOY_PHASE"],method="pearson")
      quantiles$RMSE[q] <- sqrt(mean((temps_int_pheno_opt$DOY-temps_int_pheno_opt$DOY_PHASE)^2))
      quantiles$ME[q] <- mean(abs(temps_int_pheno_opt$DOY-temps_int_pheno_opt$DOY_PHASE))
      
      
      ### Comparison of statistics
      if(quantiles$ME[q] < ME_MIN) {
        temps_int_pheno_final <- temps_int_pheno_opt
        ME_MIN <- quantiles$ME[q]
        Q_MIN <- quantiles$Q[q]
      }
      
      setTxtProgressBar(pq, q)
    }

    write.csv2(quantiles,
               row.names = FALSE,
               paste(OUT.DIR,'QOPT',PLANT,"-",PHASE,"_",YEAR,"_F1",F.STD*10,".csv",sep=""))
    close(pq)
    temps_int_pheno <- temps_int_pheno_final
    head(temps_int_pheno)
  return(temps_int_pheno)
}
