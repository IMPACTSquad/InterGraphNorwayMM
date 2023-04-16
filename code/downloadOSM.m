%% downloadOSM
% The OSM map data will be used to construct the graphical structure (or
% adjacency matrix), which will be used for our graph representation
% learning algorithm. The OSM map data contains information about road
% networks and intersections.
%
% Input: coordinates
% Parameter: size of the bounding box (extent) for the map
% Output: mapfile with osm file extension

% Note that HTTP API has maximum bounding box set to 0.5 degree by 0.5
% degree, which is equivalent to 55.5km x 55.5km. This is already big
% enough and we will use smaller extent size for our computational
% efficiency.

%% load landslide incidents and extract the locations of occurrences
% each landslide incident has fid, x, and y In the URL, a bounding box is
% expressed as four comma-separated numbers, in this order: left, bottom,
% right, top (min long, min lat, max long, max lat). Latitude and longitude
% are expressed in decimal degrees. North latitude is positive, south
% latitude is negative. West longitude is negative, east longitude is
% positive.
landslide_incidents = readtable("data\landslide_incidents\landslide_incidents_27341_since20150623_alongroad_norwayonly.xlsx");

% create a data array for saving
ls_extent = [];
ls_extent(:,1) = landslide_incidents.fid2;
ls_extent(:,2) = landslide_incidents.x;
ls_extent(:,3) = landslide_incidents.y;

% conversion (7 decimals, cm accuracy)
% source: https://www.usna.edu/Users/oceano/pguth/md_help/html/approx_equivalents.htm
% 0.000001 degrees = 0.11 meters

% Our meteorological and hydrological maps have 1km-resolution while
% satellite imagery maps have 10-m resolution. After many iterations, we
% will use a bounding box with size 
% 
% Results of iterations:
% 1kmx1km gives 968kb (968kb*27341/1e6 = 26.46GB)
% 1kmx1km gives 21.272560 seconds to generate adjacency graph (6.7 days)%
% 
% Decision 1: 
% For now, just use first 150 graphs for initial run and update!
% Then, a week after, we'll have findings for the entire 27,341 data!
% 
% Decisin 2:
% Use Cambridge OneDrive 5TB space for saving files :) 
% 
% Decision 3:
% Upload data files to Zenodo for space, GitHub has limits
length = 350; % meters
diffdeg = (length/2)*(0.000001/0.11);
ls_extent(:,4) = ls_extent(:,2) - diffdeg;
ls_extent(:,5) = ls_extent(:,3) - diffdeg;
ls_extent(:,6) = ls_extent(:,2) + diffdeg;
ls_extent(:,7) = ls_extent(:,3) + diffdeg;
YYYY = string(arrayfun(@(x) sprintf('%04d', x), landslide_incidents.YYYY, 'Uniform', 0));
MM = string(arrayfun(@(x) sprintf('%02d', x), landslide_incidents.MM, 'Uniform', 0));
DD = string(arrayfun(@(x) sprintf('%02d', x), landslide_incidents.DD, 'Uniform', 0));

filepath = "C:\Desktop\AI4ER\03 - MRes\Easter 2023\MRes Project\OneDrive - University of Cambridge\mres_data_map_osm";
for i = 1:numel(ls_extent(:,1))
    httpsUrl(i,1) = "https://api.openstreetmap.org/api/0.6/map?bbox=" + ...
                num2str(ls_extent(i,4)) + "," + ... 
                num2str(ls_extent(i,5)) + "," + ... 
                num2str(ls_extent(i,6)) + "," + ... 
                num2str(ls_extent(i,7));
    outputpath(i,1) = filepath + "\fid" + num2str(ls_extent(i,1)) + ...
                 "_lsdate" + YYYY(i,1) + MM(i,1) + DD(i,1) +".osm";
end

writematrix(httpsUrl,"OSMlist.txt");
writematrix(outputpath,"Namelist.txt");