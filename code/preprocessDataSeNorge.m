%% preprocessData.m
% This script extracts and preprocesses various datasets to become
% suitable for the implementation of the main machine learning model.
% These are the preprocessed variables (initialized).
clear, clc, close
feature = struct();
feature.idx = [];
feature.lstype = [];
feature.x = []; 
feature.y = [];
feature.rr = [];
feature.tg = [];
feature.tn = [];
feature.tx = [];
n_past = 10; %number of effective rainfall days 

%% landslide_incidents
% Because the raw data is in a form of geospatial and tabular file, we will
% just need to read it as a variable.
landslide_incidents = readtable('data\landslide_incidents\landslide_incidents.xlsx');
feature.idx = (1:numel(landslide_incidents.fid))';
feature.lstype = landslide_incidents.landslideType;
feature.x = landslide_incidents.x;
feature.y = landslide_incidents.y;

%% meteorological_data
% This takes 17 minutes.
% Daily precipitation and temperature data We have to consider the point in
% time from the landslide incidents so that we can properly index which
% precipitation and temperature data we should be using. 
% 
% Source:
% https://thredds.met.no/thredds/catalog/senorge/seNorge_2018/Archive/catalog.html
% 
% Our landslide incidents have the following years (9): 
% 1980, 1981, 2015, 2016, 2018, 2019, 2020, 2021, 2022 
%
% The seNorge2018 meteorological files are 18.3 GB files in total. We
% recommend dowjnloading them from our Zenodo repository and save in your
% local repository if you would like to perform the preprocessing.
% Nonetheless, we will provide the preprocessed data so that you could also
% proceed with our model.
seNorge2018_file_path = "C:\Desktop\AI4ER\03 - MRes\Easter 2023\MRes Project\seNorge_2018\";

dayCount = daysdif( datetime(landslide_incidents.YYYY,1,1),...
                    datetime(landslide_incidents.YYYY,...
                             landslide_incidents.MM,...
                             landslide_incidents.DD));
uniq_years = unique(landslide_incidents.YYYY);
for i = 1:numel(uniq_years)
    
    % load nc file
    filepath = seNorge2018_file_path + "seNorge2018_" + num2str(uniq_years(i)) + ".nc";

    % get the indices with this yyyy
    idx_yyyy = find(landslide_incidents.YYYY == uniq_years(i));
    
    % extract the lon and lat map with this yyyy, so we can get the index
    % for our landslide incident location
    lon_yyyy = ncread(filepath, "lon");
    lat_yyyy = ncread(filepath, "lat");
    
    % get the location of our landslide incident location so we can finally
    % extract the rr from their own mapping
    [k,dist] = dsearchn([lon_yyyy(:) lat_yyyy(:)],...
                [feature.x(idx_yyyy) feature.y(idx_yyyy)]);
    [row, col] =  ind2sub(size(lon_yyyy),k);

    % extract (ncread is a vector operation)
    for j = 1:numel(idx_yyyy)
        if idx_yyyy(j) == 13 %exception because the dayCount is 2, and we have to use the year before it
            
            filepath_prev = seNorge2018_file_path + "seNorge2018_" + num2str(uniq_years(i-1)) + ".nc";

            % 2 points from 2020
            feature.rr(idx_yyyy(j),9:10) = ...
                            reshape(ncread(filepath, "rr", ...
                            [row(j) col(j) dayCount(idx_yyyy(j))-(2-1)], [1 1 2]), ...
                            [numel(idx_yyyy(j)),2]);
            feature.tg(idx_yyyy(j),9:10) = ...
                            reshape(ncread(filepath, "tg", ...
                            [row(j) col(j) dayCount(idx_yyyy(j))-(2-1)], [1 1 2]), ...
                            [numel(idx_yyyy(j)),2]);
            feature.tn(idx_yyyy(j),9:10) = ...
                            reshape(ncread(filepath, "tn", ...
                            [row(j) col(j) dayCount(idx_yyyy(j))-(2-1)], [1 1 2]), ...
                            [numel(idx_yyyy(j)),2]);
            feature.tx(idx_yyyy(j),9:10) = ...
                            reshape(ncread(filepath, "tx", ...
                            [row(j) col(j) dayCount(idx_yyyy(j))-(2-1)], [1 1 2]), ...
                            [numel(idx_yyyy(j)),2]);


            % 8 points from 2019
            feature.rr(idx_yyyy(j),1:8) = ...
                            reshape(ncread(filepath_prev, "rr", ...
                            [row(j) col(j) 365-(8-1)], [1 1 8]), ...
                            [numel(idx_yyyy(j)),8]);
            feature.tg(idx_yyyy(j),1:8) = ...
                            reshape(ncread(filepath_prev, "tg", ...
                            [row(j) col(j) 365-(8-1)], [1 1 8]), ...
                            [numel(idx_yyyy(j)),8]);
            feature.tn(idx_yyyy(j),1:8) = ...
                            reshape(ncread(filepath_prev, "tn", ...
                            [row(j) col(j) 365-(8-1)], [1 1 8]), ...
                            [numel(idx_yyyy(j)),8]);
            feature.tx(idx_yyyy(j),1:8) = ...
                            reshape(ncread(filepath_prev, "tx", ...
                            [row(j) col(j) 365-(8-1)], [1 1 8]), ...
                            [numel(idx_yyyy(j)),8]);

        else
            feature.rr(idx_yyyy(j),1:n_past) = ...
                            reshape(ncread(filepath, "rr", ...
                            [row(j) col(j) dayCount(idx_yyyy(j))-(n_past-1)], [1 1 n_past]), ...
                            [numel(idx_yyyy(j)),n_past]);
            feature.tg(idx_yyyy(j),1:n_past) = ...
                            reshape(ncread(filepath, "tg", ...
                            [row(j) col(j) dayCount(idx_yyyy(j))-(n_past-1)], [1 1 n_past]), ...
                            [numel(idx_yyyy(j)),n_past]);
            feature.tn(idx_yyyy(j),1:n_past) = ...
                            reshape(ncread(filepath, "tn", ...
                            [row(j) col(j) dayCount(idx_yyyy(j))-(n_past-1)], [1 1 n_past]), ...
                            [numel(idx_yyyy(j)),n_past]);
            feature.tx(idx_yyyy(j),1:n_past) = ...
                            reshape(ncread(filepath, "tx", ...
                            [row(j) col(j) dayCount(idx_yyyy(j))-(n_past-1)], [1 1 n_past]), ...
                            [numel(idx_yyyy(j)),n_past]);
    end
    
end




%%
seNorgeOpenDAP_file_path = "https://thredds.met.no/thredds/dodsC/senorge/";


dem_path = "geoinfo/seNorge2018_dem_UTM33.nc";
laf_path = "geoinfo/seNorge2018_max_laf_UTM33.nc";
snow_swepr = "seNorge_snow/swepr/swepr_2023.nc";
snow_swe = "seNorge_snow/swe/swe_2023.nc";