#-----------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------
#Wrapper script that runs R functions to download, filter and interpolate phenological observations
#provided by the German Weather Service (DWD)
#-----------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------
#contact: markus.moeller@julius-kuehn.de
#-----------------------------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------------------------
print("Definition of directories, year, crop type and phases")
#-----------------------------------------------------------------------------------------------------
FUNC.DIR <- "d:/Dropbox/GIT/rPhaseGit/FUNCTION/"
IN.DIR <- "d:/Dropbox/GIT/rPhaseGit/INPUT/"
OUT.DIR <- "d:/Dropbox/GIT/rPhaseGit/OUTPUT/"
PLANT=202
PHASE=15
YEAR=2000

#-----------------------------------------------------------------------------------------------------
print("Load/install all required packages")
#-----------------------------------------------------------------------------------------------------
source(file.path(FUNC.DIR,"fLoadAndInstall.R"))
fLoadAndInstall()

#-----------------------------------------------------------------------------------------------------
#Download and import of phenological observations
#-----------------------------------------------------------------------------------------------------
source(file.path(FUNC.DIR,"fDownloadPhenObs.R"))
fDownloadPhenObs(PLANT = PLANT,
                 URL="ftp://opendata.dwd.de/climate_environment/CDC/observations_germany/phenology/",
                 IN.DIR,
                 OUT.DIR,
                 replace=TRUE,
                 annual=TRUE)

source(file.path(FUNC.DIR,"fImportPhenObs.R"))
PHENO.OBS <- fImportPhenObs(OBS.DIR=OUT.DIR,
                            PLANT = PLANT,
                            annual=TRUE)

#-----------------------------------------------------------------------------------------------------
#Creating spatial data frame of phase- and year-specific phenological observations
#-----------------------------------------------------------------------------------------------------
source(file.path(FUNC.DIR,"fPhaseStation.R"))
PHASE.STATION <- fPhaseStation(PHENO.OBS = PHENO.OBS,
                               IN.DIR = IN.DIR,
                               PHENO.STATIONS = "PHENO_STATION_EPSG31467.shp",
                               PHASE,
                               PLANT,
                               YEAR,
                               start.Phase=10,
                               start.DOY=1,
                               OL.RM = TRUE)

#-----------------------------------------------------------------------------------------------------
#Import daily temperatures for a specific year
#-----------------------------------------------------------------------------------------------------
source(file.path(FUNC.DIR,"fLoadTemp.R"))
TEMP.GRID <- fLoadTemp(PHASE.STATION = PHASE.STATION,
                       IN.DIR=IN.DIR,
                       PARAMETER = "tmit_",
                       YEAR)

#-----------------------------------------------------------------------------------------------------
#Calculation of effective temperatures
#-----------------------------------------------------------------------------------------------------
source(file.path(FUNC.DIR,"fTeffSum.R"))
TEMP.PHENO <- fTeffSum(TEMP.GRID=TEMP.GRID,
                       PHASE.STATION=PHASE.STATION,
                       T.BASE = TRUE)

#-----------------------------------------------------------------------------------------------------
#Derivation and assessment of critical effective temperature variants
#-----------------------------------------------------------------------------------------------------
FILTER <- seq(1,3,0.5)
for (F.STD in FILTER) {
source(file.path(FUNC.DIR,"fDoyCrit.R"))
TEMP.PHENO.DOY <- fDoyCrit(TEMP.PHENO=TEMP.PHENO,
                                 OUT.DIR,
                                 F.STD=F.STD,
                                 Q1=0.3,
                                 Q2=0.7)
}

source(file.path(FUNC.DIR,"fFilterAssessment.R"))
fFilterAssessment(IN.DIR="d:/Dropbox/GIT/rPhaseGit/OUTPUT/",
                  PLANT,
                  PHASES=PHASE,
                  YEARS=YEAR,
                  MAE=FALSE)


#-----------------------------------------------------------------------------------------------------
#Extract and interpolate optimal observation variant
#-----------------------------------------------------------------------------------------------------
source(file.path(FUNC.DIR,"fOptShp.R"))
fOptShp(SHP.DIR="d:/Dropbox/GIT/rPhaseGit/OUTPUT/",
        OPT.DIR="d:/Dropbox/GIT/rPhaseGit/OUTPUT/",
        OUT.DIR="d:/Dropbox/GIT/rPhaseGit/OUTPUT/",
        PLANT,
        PHASE)

source(file.path(FUNC.DIR,"fPhaseInterpolation.R"))
fPhaseInterpolation(PLANT,
                    PHASE,
                    YEAR,
                    SHP.EPSG = 31467,
                    SHP.DIR = OUT.DIR,
                    DEM.DIR = IN.DIR,
                    DEM.GRID = "DGM1000_EPSG31467.asc",
                    DEM.EPSG = 31467,
                    OUT.DIR  = OUT.DIR,
                    KRIGE = TRUE,
                    SPLINE = FALSE,
                    VALIDATION = TRUE,
                    SPACC = TRUE)
