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
print("Working directory, data and settings")
#-----------------------------------------------------------------------------------------------------
FUNC.DIR <- #directory containing functions
IN.DIR <- #directory comtaining input data
OUT.DIR <- #directory storing output data
YEAR <- #year
PLANT <- #plant name ID
PHASES <- #phase name IDs

#-----------------------------------------------------------------------------------------------------
print("Load all required packages and download/install non-existent packages")
#-----------------------------------------------------------------------------------------------------
source(file.path(FUNC.DIR,"fLoadAndInstall.R"))
fLoadAndInstall()

#-----------------------------------------------------------------------------------------------------
#Download and unzip station-based phenological observations from DWD Climate Data Center server
#-----------------------------------------------------------------------------------------------------
source(file.path(FUNC.DIR,"fDownloadPhenObs.R"))
fDownloadPhenObs(PLANT = PLANT,
                 URL="ftp://opendata.dwd.de/climate_environment/CDC/observations_germany/phenology/",
                 IN.DIR,
                 OUT.DIR,
                 replace=TRUE,
                 annual=TRUE)


#-----------------------------------------------------------------------------------------------------
print("Call functions")
#-----------------------------------------------------------------------------------------------------
#Download and unzip station-based phenological observations from Climate Data Center server
#-----------------------------------------------------------------------------------------------------
fDownloadPhenObs(PLANT = PLANT,
               #URL="ftp://ftp-cdc.dwd.de/pub/CDC/observations_germany/phenology/",
               URL="ftp://opendata.dwd.de/climate_environment/CDC/observations_germany/phenology/",
               IN.DIR="_input/",
               OUT.DIR = "_output/",
               replace=T,
               annual=T)

#-----------------------------------------------------------------------------------------------------
#Import downloaded phenological observations
#-----------------------------------------------------------------------------------------------------
PHENO.OBS <- fImportPhenObs(W.DIR,
                            IN.DIR,
                            PLANT,
                            annual=T)
#-----------------------------------------------------------------------------------------------------
#Creating spatial data frame of phenological observations
#-----------------------------------------------------------------------------------------------------
PHASE.STATION <- fPhaseStation(PHENO.OBS=PHENO.OBS,
                                IN.DIR=IN.DIR,
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
