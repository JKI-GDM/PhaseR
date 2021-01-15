#-----------------------------------------------------------------------------------------------------
print("Assessment of filtered observation variants")
#-----------------------------------------------------------------------------------------------------
fFilterAssessment <- function(IN.DIR,
                              PLANT,
                              PHASES,
                              YEARS){

for(PHASE in PHASES){
###Summarize all phase- and plant-specific accuracy metrics  
setwd(file.path(IN.DIR))
l.cv <- list.files(pattern="*.csv$")
l.cv.p <- mixedsort(grep(paste("CV_",PLANT,"-",PHASE,"_*",sep=""),l.cv,value=TRUE))

df.cv <- data.frame(matrix(nrow = 0,ncol=9))
for(i in 1:length(l.cv.p)){
  df.cv <- rbind(df.cv,read.csv2(l.cv.p[i])[[1]])
}
colnames(df.cv) <- read.csv2(l.cv.p[i])[[2]]
df.cv$OPT <- df.cv$SN*df.cv$COR/df.cv$MAE
write.csv2(df.cv,paste("ACC_",PLANT,"-",PHASE,".csv",sep=""),
           row.names = FALSE)


###Detect optimal filtering variants  
df.cv.max <- data.frame(matrix(nrow = 0,ncol=9))
for(YEAR in YEARS){
df.cv.y <- df.cv[which(df.cv$YEAR==YEAR),] 
x <- df.cv.y[which(df.cv.y$OPT==max(df.cv.y$OPT)),][1,]
df.cv.max <- rbind(df.cv.max,x)
write.csv2(df.cv.max,paste("OPT_",PLANT,"-",PHASE,".csv",sep=""),
           row.names = FALSE)
}
}
}
