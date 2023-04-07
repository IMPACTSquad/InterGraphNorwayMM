# **Meteorological Data**

## **Preview**
<p align="center">
    <img src="assets/image.png" width="100%"\>
</p>

## **Metadata**
1. **seNorge_2018**
    - Key Variables: 
        - Precipitation
        - Temperature
    - Author: Norwegian Meteorological Institute (MET Norway)
    - Date: Various
    - Descripton: seNorge_2018 is an observational gridded dataset. The data sources are: the Norwegian Meteorological Institute Climate Database, the Swedish Meteorological and Hydrological Institute Open Data API, the Finnish Meteorological Institute open data API and the European Climate Assessment & Dataset.
    - Source: [https://github.com/metno/seNorge_docs/wiki/seNorge_2018](https://github.com/metno/seNorge_docs/wiki/seNorge_2018)
    - License:
        - [Norwegian Licence for Open Government Data (NLOD) 1.0](https://data.norge.no/nlod/en/1.0)
        - [Creative Commons Attribution 4.0 International (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/)
    - Coordinate Reference System: EPSG:8687 - Slovenia 1996 / UTM zone 33N
    - Spatial Resolution: 1 kilometer (~0.621 mile)
2. **MET Nordic dataset**
    - Key Variables: 
        - Altitude
        - Land Area Fraction
        - Air Temperature (2m)
        - Air Pressure at Sea Level
        - Cloud Area Fraction
        - Relative Humidity (2m)
        - Wind Speed (10m)
        - Wind Direction (10m)
    - Author: Norwegian Meteorological Institute (MET Norway)
    - Date: Various
    - Descripton: The MET Nordic dataset consists of post-processed products that (a) describe the current and past weather (analyses), and (b) gives our best estimate of the weather in the future (forecasts). The products integrate output from MetCoOp Ensemble Prediction System (MEPS) as well as measurements from various observational sources, including crowdsourced weather stations. These products are deterministic, that is they contain only a single realization of the weather. The forecast product forms the basis for the forecasts on Yr (https://www.yr.no)
    - Source: [https://github.com/metno/NWPdocs/wiki/MET-Nordic-dataset](https://github.com/metno/NWPdocs/wiki/MET-Nordic-dataset)
    - License:
        - [Norwegian Licence for Open Government Data (NLOD) 1.0](https://data.norge.no/nlod/en/1.0)
        - [Creative Commons Attribution 4.0 International (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/)
    - Coordinate Reference System: EPSG:8687 - Slovenia 1996 / UTM zone 33N
    - Spatial Resolution: 1 kilometer (~0.621 mile)

## **File Description**
- filename1 (brief description)
- filename2 (brief description)

## **Field Names**
1. **seNorge_2018**
    - `rr`: Daily total of precipitation (precipitation day definition: yesterday at 06 UTC / today at 06 UTC) - mm/day
    - `tg`: Mean temperature (yesterday at 06 UTC / today at 06 UTC) - Celsius degrees
    - `tn`: Minimum temperature consistent with TG/TX (yesterday at 18 UTC / today at 18 UTC) - Celsius degrees
    - `tx`: Maximum temperature consistent with TG/TN (yesterday at 18 UTC / today at 18 UTC) - Celsius degrees
2. **MET Nordic dataset**
    - `altitude`: distance above sea level - m
    - `land_area_fraction`: fraction of the area that is land
    - `air_temperature_2m`: Instantaneous temperature at 2 m. Downscaling from 2.5 km to 1 km using elevation gradient approach. Bias-correction using optimal interpolation observations from Netatmo, WMO-stations from MET and FMI, and other non-WMO stations in Norway. Forecast correction using a weighted average of recent temperature biases. - K 
    - `air_pressure_at_sea_level`: 	Instantaneous air pressure reduced to sea level. Bilinear interpolation from 2.5 km NWP. - Pa
    - `cloud_area_fraction`: Fraction of sky covered by cloud. Bias corrected using webcameras from Luftambulansen. Correction to forecast 3 hours into the future. Bilinear interpolation from 2.5 km NWP. - 1
    - `relative_humidity_2m`: Instantaneous relative humidity at 2 m. Bilinear interpolation from 2.5 km NWP. - 1
    - `wind_speed_10m`: 10 minute average speed of wind at 10m. Downscaling using an elevation gradient method. - m/s
    - `wind_direction_10m`: 10 minute average direction of wind at 10m. Direction is where wind is from, and 0 indicates wind from North. Downscaling using an elevation gradient method. Nearest neighbour interpolation from 2.5 km NWP. - degree

## **Technical References**
1. **seNorge_2018**
    - [Lussana, C., Tveito, O. E., Dobler, A., and Tunheim, K.: seNorge_2018, daily precipitation, and temperature datasets over Norway, Earth Syst. Sci. Data, 11, 1531–1551, https://doi.org/10.5194/essd-11-1531-2019, 2019.](https://essd.copernicus.org/articles/11/1531/2019/)
    - [Lussana C. seNorge observational gridded datasets. seNorge_2018, version 20.05. arXiv preprint arXiv:2008.02021. 2020 Aug 5.](https://arxiv.org/abs/2008.02021)
    - [seNorge_2018 GitHub Page](https://github.com/metno/seNorge_docs/wiki/seNorge_2018)
2. **MET Nordic dataset**
    - [MET Nordic dataset GitHub Page](https://github.com/metno/NWPdocs/wiki/MET-Nordic-dataset)