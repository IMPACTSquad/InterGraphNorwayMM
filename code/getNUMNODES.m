%% name file
clear all
clc
inputpath = "C:\Desktop\AI4ER\03 - MRes\Easter 2023\MRes Project\OneDrive - University of Cambridge\mres_data_map_osm";
outputpath = "C:\Desktop\AI4ER\03 - MRes\Easter 2023\MRes Project\ArcticCCAM\data\road_network";
contents = struct2table(dir(inputpath));
filename = string(contents.name(find(contents.isdir==0)));
tic
a = getINODES(inputpath,filename);
toc


%% 
function [a] = getINODES(inputpath,filename)
    ticBytes(gcp);
    parfor i = 1:numel(filename)
        disp(i)
        try
            [parsed_osm, ~] = parse_openstreetmap(convertStringsToChars(inputpath+"\"+filename(i)));
            [~, intersection_node_indices] = extract_connectivity(parsed_osm);
            a(i,1) = numel(intersection_node_indices);
        catch
            a(i,1) = 0;
        end
        toc
    end
    tocBytes(gcp)
end