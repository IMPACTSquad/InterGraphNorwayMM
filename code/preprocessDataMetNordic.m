%% preprocessData.m
% This script extracts and preprocesses various datasets to become
% suitable for the implementation of the main machine learning model.
% These are the preprocessed variables (initialized).
clear, clc, close
feature = struct();

feature.idx = [];
feature.fid = [];
feature.lstype = [];
feature.x = []; 
feature.y = [];
feature.YYYY = [];
feature.MM = [];
feature.DD = [];
feature.H = [];
feature.M = [];
feature.S = [];

feature.altitude = []; %m
feature.land_area_fraction = []; %l
feature.air_temperature_2m = []; %K
feature.air_pressure_at_sea_level = []; %Pa
feature.cloud_area_fraction = []; %l
feature.relative_humidity_2m = []; %l
feature.wind_speed_10m = []; %m/s
feature.wind_direction_10m = []; %degree

countHeff = 24*3; %number of effective rainfall event hours preceding the event

%% landslide_incidents
% Because the raw data is in a form of geospatial and tabular file, we will
% just need to read it as a variable.
landslide_incidents = readtable('data\landslide_incidents\landslide_incidents.xlsx');
rawCount = numel(landslide_incidents.fid);
feature.idx = (1:(rawCount-2))'; %we remove 1980 and 1981 because it's not covered by MetNordic
feature.fid = landslide_incidents.landslideType(3:rawCount);
feature.lstype = landslide_incidents.landslideType(3:rawCount);
feature.x = landslide_incidents.x(3:rawCount);
feature.y = landslide_incidents.y(3:rawCount);
feature.YYYY = landslide_incidents.YYYY(3:rawCount);
feature.MM = landslide_incidents.MM(3:rawCount);
feature.MM = string(arrayfun(@(x) sprintf('%02d', x), feature.MM, 'Uniform', 0));
feature.DD = landslide_incidents.DD(3:rawCount);
feature.DD = string(arrayfun(@(x) sprintf('%02d', x), feature.DD, 'Uniform', 0));
feature.H = landslide_incidents.HH(3:rawCount);
feature.H = string(arrayfun(@(x) sprintf('%02d', x), feature.H, 'Uniform', 0));
feature.M = landslide_incidents.MM_1(3:rawCount);
feature.M = string(arrayfun(@(x) sprintf('%02d', x), feature.M, 'Uniform', 0));
feature.S = landslide_incidents.SS(3:rawCount);
feature.S = string(arrayfun(@(x) sprintf('%02d', x), feature.S, 'Uniform', 0));

%% meteorological_data
% Here, we will disreagard the first two points 1980 and 1981 because we do
% not have wind data for them. We are using this operational:
% https://github.com/metno/NWPdocs/wiki/MET-Nordic-dataset  is the analysis
% product, which contains the weather for a given hour.

% The MET Nordic dataset consists of post-processed products that (a)
% describe the current and past weather (analyses), and (b) gives our best
% estimate of the weather in the future (forecasts). The products integrate
% output from MetCoOp Ensemble Prediction System (MEPS) as well as
% measurements from various observational sources, including crowdsourced
% weather stations. These products are deterministic, that is they contain
% only a single realization of the weather.

% The forecast product forms the basis for the forecasts on Yr
% (https://www.yr.no). Both analyses and forecasts and are freely available
% for download.

% Use OpenDAP
MetNordicOpenDAP_file_path = "https://thredds.met.no/thredds/dodsC/metpparchivev3/";
tic

% Extract meteorological data for each observations
for i = 1:numel(feature.idx)

    % load nc file
    filepath = MetNordicOpenDAP_file_path + num2str(feature.YYYY(i)) + ...
              "/" + num2str(feature.MM(i)) + "/" + num2str(feature.DD(i)) + ...
              "/met_analysis_1_0km_nordic_" + num2str(feature.YYYY(i)) + ...
              num2str(feature.MM(i)) + num2str(feature.DD(i)) + "T" + ...
              num2str(feature.H(i)) + "Z.nc";

    % extract the lon and lat map with this yyyy, so we can get the index
    % for our landslide incident location
    lon_i = ncread(filepath, "longitude");
    lat_i = ncread(filepath, "latitude");

    % get the location of our landslide incident location so we can finally
    % extract the rr from their own mapping
    [k,dist] = dsearchn([lon_i(:) lat_i(:)],...
                [feature.x(i) feature.y(i)]);
    [row, col] =  ind2sub(size(lon_i),k);

    % extract
    feature.altitude(i,1) = ncread(filepath, "altitude", ...
                            [row col ], [1 1]); %m
    feature.land_area_fraction(i,1) = ncread(filepath, "land_area_fraction", ...
                            [row col ], [1 1]); %l
    feature.air_temperature_2m(i,1) = ncread(filepath, "air_temperature_2m", ...
                            [row col 1], [1 1 1]); %K
    feature.air_pressure_at_sea_level(i,1) = ncread(filepath, "air_pressure_at_sea_level", ...
                            [row col 1], [1 1 1]); %Pa
    feature.cloud_area_fraction(i,1) = ncread(filepath, "cloud_area_fraction", ...
                            [row col 1], [1 1 1]); %l
    feature.relative_humidity_2m(i,1) = ncread(filepath, "relative_humidity_2m", ...
                            [row col 1], [1 1 1]); %l
    feature.wind_speed_10m(i,1) = ncread(filepath, "wind_speed_10m", ...
                            [row col 1], [1 1 1]); %m/s
    feature.wind_direction_10m(i,1) = ncread(filepath, "wind_direction_10m", ...
                            [row col 1], [1 1 1]); %degree
    disp(i)
    toc
end

save("data\meteorological_data\data_features_MetNordic.mat","feature",'-mat');

%% Supplementary
% rain - accumulation is about three days
% cumulative rainfall threshold trigger of landslides
% https://iopscience.iop.org/article/10.1088/1755-1315/893/1/012011/pdf#:~:text=The%20peak%20rainfall%20intensity%20occurs,hours%20before%20a%20landslide%20occur.
% https://www.proquest.com/openview/474b9296ec582cc47faf0f0407ee3b92/1?cbl=2048001&pq-origsite=gscholar&parentSessionId=q40Arzl8fbcxC2y0nOuHi2xlpdngtIOJSqrltP38nYc%3D
% http://rainfallthresholds.irpi.cnr.it/Article_MAP_r2v14_16nov2006.pdf