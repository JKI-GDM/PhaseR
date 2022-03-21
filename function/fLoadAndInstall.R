#-----------------------------------------------------------------------------------------------------
print("Load all required packages or functions and dowload/install non-existent packages")
#-----------------------------------------------------------------------------------------------------
fLoadAndInstall <- function(mypkg=c("automap",
                                    "caret",
                                    "docstring",
                                    "gstat",
                                    "gtools",
                                    "chron",
                                    "data.table",
                                    "dplyr",
                                    "fields",
                                    "foreign",
                                    "geosphere",
                                    "grid",
                                    "gstat",
                                    "intamap",
                                    "Metrics",
                                    "parallel",
                                    "raster",
                                    "RCurl",
                                    "roxygen2",
                                    "stringr",
                                    "tidyselect",
                                    "sf",
                                    "utils",
                                    "fields")) {
  for(i in seq(along=mypkg)){
    if (!is.element(mypkg[i],installed.packages()[,1])){install.packages(mypkg[i])}
    library(mypkg[i], character.only=TRUE)
  }
}

#Function for R2 calculation
r2 <- function(pred, obs, formula = "corr", na.rm = FALSE) {
  n <- sum(complete.cases(pred))
  switch(formula,
         corr = cor(obs, pred, use = ifelse(na.rm, "complete.obs", "everything"))^2,
         traditional = 1 - (sum((obs-pred)^2, na.rm = na.rm)/((n-1)*var(obs, na.rm = na.rm))))
} 
