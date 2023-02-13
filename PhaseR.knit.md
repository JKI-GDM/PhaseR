---
title: "PhaseR"
title-block-banner: true
author:
  - name: Markus Möller
    orcid: 0000-0002-1918-7747
    affiliation:
      - name: Julius Kühn Institute (JKI) -- Federal Research Centre for Cultivated Plants, Institute for Crop and Soil Science, Bundesallee 58, 38116 Braunschweig, Germany, markus.moeller@julius-kuehn.de
format: 
  html:
    toc: true
    number-sections: true
    number-depth: 2
    code-fold: false
  pdf:
    toc: true
    number-sections: true
    number-depth: 2
    colorlinks: true
editor: visual
date: "2023-02-13"
bibliography: references.bib
---


This document describes a [wrapper R script](https://github.com/FLFgit/PhaseR/blob/master/fPhaseR.R) that runs R functions to download, filter and interpolate Germany-wide phenological observations provided by the German Weather Service [@kaspar_overview_2015; @bruns_vorschriften_2015] using the example of the phenological phase *shooting* (phase ID = 15) of winter wheat (plant ID = 202) for the year 2000. The functions are based on the PHASE model introduced by @gerstmann_phase_2016 and are documented in detail on the GitHub repository [PhaseR](https://github.com/FLFgit/PhaseR/wiki). The plant and phase IDs are listed in @moller_phenowin_2020.

## Settings and packages

#### Definition of directories, year, crop type and phases


::: {.cell}

```{.r .cell-code}
FUNC.DIR <- #directory containing functions
IN.DIR   <- #directory containing input data
OUT.DIR  <- #directory for storing output data
YEAR <- 2000
PLANT <- 202
PHASE <- 15
```
:::

::: {.cell}

:::


#### Load/install all required packages


::: {.cell}

```{.r .cell-code}
source(file.path(FUNC.DIR,"fLoadAndInstall.R"))
fLoadAndInstall()
```
:::


## Download and import of phenological observations

In the phenological observation network, annual and immediate reports are distinguished, which is taken into account when executing the function (parameter annual=TRUE). The annual reports are made available after the respective vegetation period, whereby the data set is subjected to a quality control. The immediate reports are available a few days after the observations, but their number is smaller than that of the annual reports. Also, the observed phases are not always identical [@kaspar_overview_2015]. Function `fDownloadPhenObs()` downloads all available plant-specific observations. In the download result, the original German column names are transferred into English.


::: {.cell}

```{.r .cell-code}
source(file.path(FUNC.DIR,"fDownloadPhenObs.R"))
fDownloadPhenObs(PLANT = PLANT,
                 URL="ftp://opendata.dwd.de/climate_environment/CDC/observations_germany/phenology/",
                 IN.DIR,
                 OUT.DIR,
                 replace=TRUE,
                 annual=TRUE)
```
:::


Function `fImportPhenObs` imports the result of function `fDownloadPhenObs`. @fig-PhasePlot displays the available observations for all years and phases.


::: {.cell}

```{.r .cell-code}
source(file.path(FUNC.DIR,"fImportPhenObs.R"))
PHENO.OBS <- fImportPhenObs(OBS.DIR=OUT.DIR,
                            PLANT = PLANT,
                            annual=TRUE)
```
:::

::: {.cell}
::: {.cell-output-display}
![Yearly temporal observation coverage on the example of the winter wheat phases  (plant ID = 202, 10 - sowing, 12 - emergence, 15 – shooting, 18 – heading, 19 - milk ripening, 21 - yellow ripening, 24 - harvest).](PhaseR_files/figure-html/fig-PhasePlot-1.png){#fig-PhasePlot width=672}
:::
:::


## Creating spatial data frame of phase- and year-specific phenological observations

The function `fPhaseStation()` couples year- and phase-specific observations and corresponding phenological stations. A [shapefile](https://en.wikipedia.org/wiki/Shapefile) of all available phenological stations is related to year- and phase-specific observations (output from function `fImportPhenObs()`). During the coupling operation, the actual observed phase-specific days of the year (DOY) and the corresponding starting DOYs are determined. There are two options to determine starting DOYs (column "DOY_start"):

1.  Summer crops -\> DOY_start=1 or

2.  Winter crops -\> for spring and summer phases of the current year DOY_start corresponds to the starting DOY of phase 10 observed in previous year.

The OL.RM=TRUE parameter activates an operation that removes outliers using the [interquartile range](https://en.wikipedia.org/wiki/Interquartile_range) (IQR) criterion.

The function results in a shapefile of observed phase- and year-specific Germany-wide events (@fig-PhaseStation). In addition, every file contains the starting DOY, on which the crop-specific vegetation period begins. The start DOY for summer crops can be defined by the user (default value "start.DOY=1"). For winter crops, the start DOY corresponds to the DOY of a user-defined phase of the previous year, with the default value "start.Phase=10" (@tbl-PhaseStation).


::: {.cell}

```{.r .cell-code}
source(file.path(FUNC.DIR,"fPhaseStation.R"))
PHASE.STATION <- fPhaseStation(PHENO.OBS = PHENO.OBS,
                               IN.DIR = IN.DIR,
                               PHENO.STATIONS = "PHENO_STATION_EPSG31467.shp",
                               PHASE=PHASE,
                               PLANT=PLANT,
                               YEAR=YEAR,
                               start.Phase=10,
                               start.DOY=1,
                               OL.RM = TRUE)
```
:::

::: {.cell}
::: {.cell-output-display}
![Germany-wide observations for the phenological phase shooting of Winter Wheat in 2000.](PhaseR_files/figure-html/fig-PhaseStation-1.png){#fig-PhaseStation width=672}
:::
:::

::: {#tbl-PhaseStation .cell .tbl-cap-location-top tbl-cap='Excerpt of an attribute table of year- and phase-specific phenological stations on example of the winter wheat phase *shooting* in the year 2000.'}
::: {.cell-output-display}
|    | STATION|     ID|       X|       Y|GRID_ID  | QL| YEAR| PLANT| PHASE|     DATE| QF| DOY| DOY_start|
|:---|-------:|------:|-------:|-------:|:--------|--:|----:|-----:|-----:|--------:|--:|---:|---------:|
|569 |   10725| 268938| 3396415| 5273501|33965273 | 10| 2000|   202|    15| 20000420|  1| 110|       291|
|568 |   10723| 268976| 3410415| 5279501|34105279 | 10| 2000|   202|    15| 20000407|  1|  97|       281|
|574 |   10768| 269201| 3426415| 5280501|34265280 | 10| 2000|   202|    15| 20000427|  1| 117|       275|
|578 |   10802| 268105| 3456415| 5286501|34565286 | 10| 2000|   202|    15| 20000511|  1| 131|       300|
|565 |   10700| 268439| 3505415| 5288501|35055288 | 10| 2000|   202|    15| 20000411|  1| 101|       295|
|576 |   10786| 268538| 3523415| 5290501|35235290 | 10| 2000|   202|    15| 20000412|  1| 102|       289|
:::
:::


## Import daily temperatures

The function `fLoadTemp()` imports an interpolated temperature data set for a specific vegetation period. The Germany-wide data set is provided by the German Weather Service [@janssen_beschreibung_2009]. For this application, data of each single year are stored in csv format, which is related to a polygon shape file representing a Germany-wide weather grid:

-   Column 1: GRID_ID of WEATHER_GRID_EPSG31467.shp and

-   Columns 2-367: Daily temperatures \[°C x 10\].

For summer crops, the year-specific temperatures are extracted. For winter crops, the temperatures of the previous year are also considered, starting with the minimum observed DOY of the start phase defined in the function `fPhaseStation.`@tbl-TempGrid shows an excerpt of an interpolated temperature data set \[°C x 10\] for the vegetation period of winter wheat in the year 2000. The first DOY of the starting phase *sowing* (phase ID = 10) was observed on 19 August 1999 (DOY = 231), which results in the DOY difference 231-365=-134 and the corresponding temperatures.


::: {.cell}

```{.r .cell-code}
source(file.path(FUNC.DIR,"fLoadTemp.R"))
TEMP.GRID <- fLoadTemp(PHASE.STATION = PHASE.STATION,
                       IN.DIR=IN.DIR, 
                       PARAMETER = "tmit_",
                       YEAR)
```
:::

::: {#tbl-TempGrid .cell .tbl-cap-location-top tbl-cap='Excerpt of an interpolated  temperature data set [°C x 10] in the vegetation period of winter wheat for the year 2000.'}
::: {.cell-output-display}
|  GRID_ID| T-134| T-133| T-132| T-131| T-130| T-129| T-128| T-127| T-126| T-125|
|--------:|-----:|-----:|-----:|-----:|-----:|-----:|-----:|-----:|-----:|-----:|
| 32805658|   152|   157|   143|   136|   165|   203|   250|   204|   186|   180|
| 32805661|   153|   158|   144|   137|   166|   204|   250|   205|   186|   181|
| 32815657|   153|   157|   144|   137|   165|   203|   250|   204|   186|   181|
| 32815658|   152|   157|   143|   136|   165|   203|   250|   204|   186|   180|
| 32815659|   152|   157|   144|   137|   165|   203|   250|   204|   186|   181|
| 32815660|   153|   157|   144|   137|   165|   203|   250|   205|   186|   181|
:::
:::


## Calculation of effective temperatures

For a specific vegetation period and phase, function `fTeffSum()` couples the phenological observations and daily mean temperatures ($T$). While a vegetation period of summer crops only considers the year of interest, a vegetation period of winter crops starts in the previous year on the DOY of sowing. During the temperature summation (@eq-Teff), plant-specific base temperatures are subtracted ($T_B$), negative temperatures are deleted and the remaining temperature values are weighted by a day length factor ($DL$). For every phase- and year-specific station, the effective temperatures ($TS^{eff}$) are then accumulated (@tbl-fTeffSum). @fig-HeatSumPlot displays a $TS^{eff}$ density plot for the phenological observations of the winter wheat phase *shooting* in the year 2000.

$$
TS^{eff} = \Sigma_{i=DOY_{start}}^{DOY_{obs}}\left((T-T_B)\times \dfrac{DL_i}{24}\right)
$$ {#eq-Teff}

@fig-HeatSumPlot shows the median and the 0.5 quantile (= median) of the value distribution as well as the limits of the single and double standard deviation (SD) for the example of the winter wheat phase *shooting*.


::: {.cell}

```{.r .cell-code}
source(file.path(FUNC.DIR,"fTeffSum.R"))
TEMP.PHENO <- fTeffSum(TEMP.GRID=TEMP.GRID, 
                       PHASE.STATION=PHASE.STATION,
                       T.BASE = TRUE)
```
:::

::: {#tbl-fTeffSum .cell .tbl-cap-location-top tbl-cap='Excerpt of an attribute table of station- and phase-specific temperature sums (TS=T_SUMS) on example of the winter wheat phase *shooting* in the year 2000.'}
::: {.cell-output-display}
|    |GRID_ID  |      LON|      LAT| STATION| ID| YEAR| PLANT| PHASE|     DATE| DOY| DOY_start|    T_SUMS|
|:---|:--------|--------:|--------:|-------:|--:|----:|-----:|-----:|--------:|---:|---------:|---------:|
|96  |33965273 | 7.631053| 47.59795|   10725|  1| 2000|   202|    15| 20000420| 110|       -75| 1168.7743|
|118 |34105279 | 7.815999| 47.65399|   10723|  2| 2000|   202|    15| 20000407|  97|       -85|  869.0156|
|143 |34265280 | 8.028835| 47.66499|   10768|  3| 2000|   202|    15| 20000427| 117|       -91|  697.0389|
|207 |34565286 | 8.427745| 47.72165|   10802|  4| 2000|   202|    15| 20000511| 131|       -66| 2063.5872|
|319 |35055288 | 9.081043| 47.74104|   10700|  5| 2000|   202|    15| 20000411| 101|       -71|  663.9686|
|374 |35235290 | 9.321216| 47.75862|   10786|  6| 2000|   202|    15| 20000412| 102|       -77|  757.0679|
:::
:::

::: {.cell}
::: {.cell-output-display}
![*TS^eff^* density plot, corresponding 0.5 median and the limits of the single and double standard deviation (SD) for the winter wheat phase *shooting* in the year 2000.](PhaseR_files/figure-html/fig-HeatSumPlot-1.png){#fig-HeatSumPlot width=672}
:::
:::


## Derivation and assessment of critical effective temperature variants

The function `fDoyCrit` filters the phase- and year-specific distribution of effective temperature sums in a two-stage procedure. First, quantiles ($Q$) with user-defined probabilities of effective temperature sums ($TS^{eff}$) are calculated (@eq-Tcrit). The resulting critical effective temperature sums ($TS^{crit}$) are used to determine the station- and phase-specific DOY ($DOY^P$) when the condition $TS^{eff} \geq TS^{crit}$ is fulfilled. Afterwards, the remaining $TS^{eff}$ distribution is statistically filtered using standard deviation variants.

$$
TS^{crit}=Q(TS^{eff})
$$ {#eq-Tcrit}

For each variant, $DOY^P$ and observed DOY values ($DOY^{obs}$) are compared by calculating the *Pearson correlation coefficient* ([$COR$](https://en.wikipedia.org/wiki/Pearson_correlation_coefficient)), *Root Mean Square Error* ([$RMSE$](https://en.wikipedia.org/wiki/Root-mean-square_deviation)), and *Mean Absolute Error* ([$MAE$](https://en.wikipedia.org/wiki/Mean_absolute_error)). By applying the function `fFilterAssessment()`, the optimal filtered observation variant ($O^{opt}$) results from the maximum value of the product of station number ($SN$) and $COR$ value. Optionally, the $MAE$ value can also be taken into account (@eq-Opt).

$$
O^{opt} = \dfrac{SN \times COR}{(MAE)}
$$ {#eq-Opt}


::: {.cell}

```{.r .cell-code}
FILTER <- seq(1,3,0.5)
for (F.STD in FILTER) {
source(file.path(FUNC.DIR,"fDoyCrit.R"))
TEMP.PHENO.DOY <- fDoyCrit(TEMP.PHENO=TEMP.PHENO, 
                                 OUT.DIR,
                                 F.STD=F.STD,
                                 Q1=0.3,
                                 Q2=0.7)
}
```
:::

::: {.cell}

```{.r .cell-code}
source(file.path(FUNC.DIR,"fFilterAssessment.R"))
fFilterAssessment(IN.DIR=OUT.DIR,
                  PLANT,
                  PHASES=PHASE,
                  YEARS=YEAR,
                  MAE=FALSE)
```
:::


@tbl-FilterAsessment shows the assessment results for the winter wheat phase *shooting* in 2000. According to this, the variant with $Q=0.45$ and $F.STD=1$ proved to be optimal (fourth line). It is worth mentioning that the number of stations with $SN=565$ is significantly smaller than the original number of observations (@fig-PhaseStation), where especially the standard deviation has the greatest filtering effect.


::: {#tbl-FilterAsessment .cell .tbl-cap-location-top tbl-cap='Accuarcy metrics and assessment results for variants of quantiles and standard deviation filters on example of the winter wheat phase *shooting* in the year 2000.'}
::: {.cell-output-display}
|Q    |RMSE |MAE  |SN  |COR  |YEAR |STD |PLANT |PHASE |OPT |
|:----|:----|:----|:---|:----|:----|:---|:-----|:-----|:---|
|0.30 |6.0  |5.1  |509 |0.75 |2000 |1.0 |202   |15    |379 |
|0.35 |5.9  |5.0  |524 |0.73 |2000 |1.0 |202   |15    |383 |
|0.40 |5.9  |4.9  |546 |0.71 |2000 |1.0 |202   |15    |387 |
|0.45 |5.9  |5.0  |565 |0.72 |2000 |1.0 |202   |15    |405 |
|0.50 |5.9  |4.9  |566 |0.71 |2000 |1.0 |202   |15    |402 |
|0.55 |5.9  |4.9  |564 |0.71 |2000 |1.0 |202   |15    |402 |
|0.60 |6.1  |5.2  |564 |0.69 |2000 |1.0 |202   |15    |388 |
|0.65 |6.3  |5.3  |556 |0.71 |2000 |1.0 |202   |15    |396 |
|0.70 |6.5  |5.7  |535 |0.68 |2000 |1.0 |202   |15    |363 |
|0.30 |8.5  |7.0  |650 |0.59 |2000 |1.5 |202   |15    |383 |
|0.35 |8.5  |7.0  |673 |0.57 |2000 |1.5 |202   |15    |385 |
|0.40 |8.5  |7.0  |699 |0.54 |2000 |1.5 |202   |15    |380 |
|0.45 |8.5  |6.9  |713 |0.54 |2000 |1.5 |202   |15    |387 |
|0.50 |8.4  |6.9  |717 |0.53 |2000 |1.5 |202   |15    |381 |
|0.55 |8.5  |7.0  |724 |0.55 |2000 |1.5 |202   |15    |395 |
|0.60 |8.7  |7.2  |726 |0.53 |2000 |1.5 |202   |15    |384 |
|0.65 |8.9  |7.4  |723 |0.53 |2000 |1.5 |202   |15    |387 |
|0.70 |9.3  |7.9  |721 |0.49 |2000 |1.5 |202   |15    |351 |
|0.30 |10.2 |8.3  |720 |0.48 |2000 |2.0 |202   |15    |342 |
|0.35 |10.5 |8.4  |755 |0.45 |2000 |2.0 |202   |15    |341 |
|0.40 |10.3 |8.3  |779 |0.45 |2000 |2.0 |202   |15    |347 |
|0.45 |10.4 |8.3  |795 |0.44 |2000 |2.0 |202   |15    |348 |
|0.50 |10.6 |8.6  |819 |0.41 |2000 |2.0 |202   |15    |339 |
|0.55 |10.8 |8.8  |837 |0.41 |2000 |2.0 |202   |15    |345 |
|0.60 |11.0 |9.0  |843 |0.40 |2000 |2.0 |202   |15    |340 |
|0.65 |11.4 |9.4  |854 |0.38 |2000 |2.0 |202   |15    |327 |
|0.70 |11.6 |9.7  |844 |0.38 |2000 |2.0 |202   |15    |324 |
|0.30 |12.0 |9.5  |770 |0.39 |2000 |2.5 |202   |15    |299 |
|0.35 |12.0 |9.5  |802 |0.37 |2000 |2.5 |202   |15    |296 |
|0.40 |11.6 |9.2  |819 |0.37 |2000 |2.5 |202   |15    |306 |
|0.45 |11.9 |9.3  |842 |0.34 |2000 |2.5 |202   |15    |286 |
|0.50 |11.9 |9.4  |862 |0.36 |2000 |2.5 |202   |15    |311 |
|0.55 |12.1 |9.6  |881 |0.34 |2000 |2.5 |202   |15    |304 |
|0.60 |12.4 |10.0 |895 |0.32 |2000 |2.5 |202   |15    |284 |
|0.65 |12.7 |10.3 |904 |0.32 |2000 |2.5 |202   |15    |292 |
|0.70 |13.2 |10.9 |911 |0.30 |2000 |2.5 |202   |15    |271 |
|0.30 |12.9 |10.1 |792 |0.34 |2000 |3.0 |202   |15    |272 |
|0.35 |12.8 |10.0 |819 |0.32 |2000 |3.0 |202   |15    |266 |
|0.40 |12.3 |9.6  |834 |0.32 |2000 |3.0 |202   |15    |270 |
|0.45 |12.6 |9.8  |859 |0.31 |2000 |3.0 |202   |15    |266 |
|0.50 |12.8 |10.0 |884 |0.31 |2000 |3.0 |202   |15    |271 |
|0.55 |13.0 |10.2 |904 |0.28 |2000 |3.0 |202   |15    |256 |
|0.60 |13.4 |10.6 |919 |0.26 |2000 |3.0 |202   |15    |238 |
|0.65 |13.8 |11.0 |933 |0.25 |2000 |3.0 |202   |15    |237 |
|0.70 |14.1 |11.5 |936 |0.26 |2000 |3.0 |202   |15    |243 |
:::
:::


## Extract and interpolate optimal observation variant

The function `fOptShp()` extracts the optimal phenological observation variant as a result of the function `fFilterAssessment()`, which is then interpolated by applying a SPLINE or KRIGE algorithm (function `fPhaseInterpolation()`). In addition, external validation is performed and global accuracy metrics and optionally (parameter `SPACC`) a spatial accuracy data set are derived.


::: {.cell}

```{.r .cell-code}
source(file.path(FUNC.DIR,"fOptShp.R"))
fOptShp(SHP.DIR=OUT.DIR,
        OPT.DIR=OUT.DIR,
        OUT.DIR=OUT.DIR,
        PLANT,
        PHASE)
```
:::

::: {.cell}

```{.r .cell-code}
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
```
:::


@fig-Interpolation-DOY and @fig-Interpolation-KSV displays the interpolated optimal phenological observation variant and the corresponding spatial accuracy (here: Kriging Standard Variation) for the winter wheat phase *shooting* in the year 2000. @tbl-Interpolation-VAM lists the external accuracy metrics *Root Mean Square Error* ([$RMSE$](https://en.wikipedia.org/wiki/Root-mean-square_deviation)), *Mean Absolute Error* ([$MAE$](https://en.wikipedia.org/wiki/Mean_absolute_error)), *Mean Squared Error* ([$MSE$](https://en.wikipedia.org/wiki/Mean_squared_error)) and *Coefficient of determination* ([$R2$](https://en.wikipedia.org/wiki/Coefficient_of_determination)).


::: {.cell}
::: {.cell-output-display}
![Interpolated optimal phenological observation variant for the winter wheat phase *shooting* in the year 2000.](PhaseR_files/figure-html/fig-Interpolation-DOY-1.png){#fig-Interpolation-DOY width=672}
:::
:::

::: {#tbl-Interpolation-VAM .cell .tbl-cap-location-top tbl-cap='Global accuarcy metrics of the interpolated optimal phenological observation variant for the winter wheat phase *shooting* in the year 2000. MAE = Mean Absolute Error, RMSE = Root Mean Square Error'}
::: {.cell-output-display}
|PLANT |PHASE |YEAR |SN  |MSE |MAE |RMSE |R2   |
|:-----|:-----|:----|:---|:---|:---|:----|:----|
|202   |15    |2000 |546 |52  |5.7 |7.2  |0.19 |
:::
:::

::: {.cell}
::: {.cell-output-display}
![Kriging Standard Variation (KSV) of the interpolated optimal phenological observation variant for the winter wheat phase *shooting* in the year 2000.](PhaseR_files/figure-html/fig-Interpolation-KSV-1.png){#fig-Interpolation-KSV width=672}
:::
:::


## Used packages


::: {.cell}
::: {.cell-output .cell-output-stdout}
```
R version 4.2.2 (2022-10-31 ucrt)
Platform: x86_64-w64-mingw32/x64 (64-bit)
Running under: Windows 10 x64 (build 19045)

Matrix products: default

locale:
[1] LC_COLLATE=German_Germany.utf8  LC_CTYPE=German_Germany.utf8   
[3] LC_MONETARY=German_Germany.utf8 LC_NUMERIC=C                   
[5] LC_TIME=German_Germany.utf8    

attached base packages:
[1] grid      stats     graphics  grDevices utils     datasets  methods  
[8] base     

other attached packages:
 [1] classInt_0.4-8     RColorBrewer_1.1-3 maptools_1.1-5     rgdal_1.6-2       
 [5] sf_1.0-9           tidyselect_1.2.0   stringr_1.4.1      roxygen2_7.2.2    
 [9] RCurl_1.98-1.9     raster_3.6-3       Metrics_0.1.4      intamap_1.4-16    
[13] geosphere_1.5-14   foreign_0.8-83     fields_14.1        viridis_0.6.2     
[17] viridisLite_0.4.1  spam_2.9-1         dplyr_1.0.10       data.table_1.14.4 
[21] chron_2.3-58       gtools_3.9.3       gstat_2.1-0        docstring_1.0.0   
[25] caret_6.0-93       lattice_0.20-45    ggplot2_3.4.0      automap_1.0-16    
[29] sp_1.5-1          

loaded via a namespace (and not attached):
 [1] colorspace_2.0-3     class_7.3-20         evd_2.3-6.1         
 [4] rstudioapi_0.14      proxy_0.4-27         listenv_0.8.0       
 [7] prodlim_2019.11.13   fansi_1.0.3          mvtnorm_1.1-3       
[10] lubridate_1.9.0      xml2_1.3.3           codetools_0.2-18    
[13] splines_4.2.2        doParallel_1.0.17    knitr_1.40          
[16] jsonlite_1.8.3       pROC_1.18.0          compiler_4.2.2      
[19] Matrix_1.5-1         fastmap_1.1.0        cli_3.4.1           
[22] htmltools_0.5.3      tools_4.2.2          dotCall64_1.0-2     
[25] gtable_0.3.1         glue_1.6.2           reshape2_1.4.4      
[28] maps_3.4.1           Rcpp_1.0.9           vctrs_0.5.0         
[31] nlme_3.1-160         iterators_1.0.14     timeDate_4021.106   
[34] gower_1.0.0          xfun_0.34            globals_0.16.1      
[37] timechange_0.1.1     lifecycle_1.0.3      future_1.29.0       
[40] terra_1.6-17         MASS_7.3-58.1        zoo_1.8-11          
[43] scales_1.2.1         ipred_0.9-13         parallel_4.2.2      
[46] yaml_2.3.6           MBA_0.0-9            gridExtra_2.3       
[49] rpart_4.1.19         reshape_0.8.9        stringi_1.7.8       
[52] highr_0.9            foreach_1.5.2        e1071_1.7-12        
[55] hardhat_1.2.0        lava_1.7.0           intervals_0.15.2    
[58] rlang_1.0.6          pkgconfig_2.0.3      bitops_1.0-7        
[61] evaluate_0.18        purrr_0.3.5          recipes_1.0.3       
[64] parallelly_1.32.1    plyr_1.8.8           magrittr_2.0.3      
[67] R6_2.5.1             generics_0.1.3       DBI_1.1.3           
[70] pillar_1.8.1         withr_2.5.0          units_0.8-0         
[73] xts_0.12.2           survival_3.4-0       nnet_7.3-18         
[76] tibble_3.1.8         future.apply_1.10.0  spacetime_1.2-8     
[79] KernSmooth_2.23-20   utf8_1.2.2           rmarkdown_2.18      
[82] FNN_1.1.3.1          ModelMetrics_1.2.2.2 digest_0.6.30       
[85] stats4_4.2.2         munsell_0.5.0       
```
:::
:::

