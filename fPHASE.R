#-----------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------
#Wrapper file for executing R scripts for downoadling and interpolating DWD phenological observation 
#-----------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------
#contact: markus.moeller@julius-kuehn.de
#-----------------------------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------------------------
print("Working directory, data and settings")
#-----------------------------------------------------------------------------------------------------
W.DIR <- #Working directory
FUNC.DIR <- #Folder containing functions
IN.DIR <- #Folder comtaining input data
OUT.DIR <- #Folder storing output data
YEAR <- #Year
PLANT <- #Plant name ID
PHASES <- #Phase name IDs

#-----------------------------------------------------------------------------------------------------
print("Load all required packages and download/install non-existent packages")
#-----------------------------------------------------------------------------------------------------
source(file.path(FUNC.DIR,"fLoadAndInstall.R"))
fLoadAndInstall()

#-----------------------------------------------------------------------------------------------------
print("Import functions")
#-----------------------------------------------------------------------------------------------------
source(file.path(W.DIR,FUNC.DIR,"fDownloadPhenObs.R"))
source(file.path(W.DIR,FUNC.DIR,"fImportPhenObs.R"))
source(file.path(W.DIR,FUNC.DIR,"fPhaseStation.R"))
source(file.path(W.DIR,FUNC.DIR,"fLoadTemp.R"))
source(file.path(W.DIR,FUNC.DIR,"fTeffSum.R"))
source(file.path(W.DIR,FUNC.DIR,"fDoyCrit.R"))
source(file.path(W.DIR,FUNC.DIR,"fPhaseKrige.R"))
#-----------------------------------------------------------------------------------------------------
print("Call functions")
#-----------------------------------------------------------------------------------------------------
#1 -- Download and unzip station-based phenological observations from Climate Data Center server
#-----------------------------------------------------------------------------------------------------
fDownloadPhenObs(PLANT = PLANT,
               #URL="ftp://ftp-cdc.dwd.de/pub/CDC/observations_germany/phenology/",
               URL="ftp://opendata.dwd.de/climate_environment/CDC/observations_germany/phenology/",
               IN.DIR="_input/",
               OUT.DIR = "_output/",
               replace=T,
               annual=T)

for(PHASE in PHASES){
#-----------------------------------------------------------------------------------------------------
#2 -- Import downloaded phenological observations
#-----------------------------------------------------------------------------------------------------
PHENO.OBS <- fImportPhenObs(W.DIR,
                            IN.DIR = "_output/",
                            PLANT = PLANT,
                            annual=T)
#-----------------------------------------------------------------------------------------------------
#3 -- Creating spatial data frame of phenological observations
#-----------------------------------------------------------------------------------------------------
PHASE.STATION <- fPhaseStation(PHENO.OBS = PHENO.OBS,
                                IN.DIR = IN.DIR,
                                PHENO.STATIONS = "PHENO_STATION_EPSG31467.shp",
                                PHASE=PHASE,
                                PLANT=PLANT,
                                YEAR=YEAR,
                                FILTER=T,
                                start.Phase="10",
                                start.Day=1)
#-----------------------------------------------------------------------------------------------------
#4 -- Import Germany-wide daily temperatures for a specific year
#-----------------------------------------------------------------------------------------------------
TEMP.GRID <- fLoadTemp(PHASE.STATION = PHASE.STATION,
                      IN.DIR=IN.DIR, 
                      PARAMETER = "tmit_")
#-----------------------------------------------------------------------------------------------------
#5 -- Calculation of effective temperature sum
#-----------------------------------------------------------------------------------------------------
TEMP.PHENO <- fTeffSum(TEMP.GRID=TEMP.GRID, 
                             PHASE.STATION=PHASE.STATION, 
                             dl=T, 
                             Tb="def",
                             T.scale=10)
#-----------------------------------------------------------------------------------------------------
#6 -- DOY determination on which a user-specific or calculated temperature sum quantile is exceeded
#-----------------------------------------------------------------------------------------------------
TEMP.PHENO.DOY <- fDoyCrit(TEMP.PHENO=TEMP.PHENO, 
                            quantDet=T, 
                            quantile=0.45,
                            fit=1)
#-----------------------------------------------------------------------------------------------------
#7 -- Interpolation of phenologoical phases
#-----------------------------------------------------------------------------------------------------
PHASE.KRIGE <- fPhaseKrige(W.DIR,
                      IN.DIR,
                      DEM.GRID = "DGM1000_EPSG31467.asc",
                      TEMP.PHENO.DOY=TEMP.PHENO.DOY)
}
