%% set path
clear, clc, close
inputpath = "C:\Desktop\AI4ER\03 - MRes\Easter 2023\MRes Project\OneDrive - University of Cambridge\mres_data_map_osm";
outputpath = "C:\Desktop\AI4ER\03 - MRes\Easter 2023\MRes Project\ArcticCCAM\data\road_network\graphData";

%% load list
numNODES = readtable("C:\Desktop\AI4ER\03 - MRes\Easter 2023\MRes Project\ArcticCCAM\data\road_network\numNODES.xlsx");
filename = string(numNODES.filename);
nnodes = numNODES.nnodes;

%% create a new list with specified minimum number of nnodes
minNodes = 2; % 2 has 12702 graphs; 3 has 9039 graphs; and 4 has 6212 graphs 
newfilename = filename(nnodes >= 2);

%% save each graph data as an exported .mat file (which will be used later for getting the features and labels for each nodes)
% (1) extract and save adj matrix; and (2) get coordinates of each node
tic
saveGRAPHdata(inputpath,outputpath,newfilename)
toc

%% function
function [] = saveGRAPHdata(inputpath,outputpath,newfilename)
    ticBytes(gcp)
    parfor i = 1:numel(newfilename)
        
        [parsed_osm, ~] = parse_openstreetmap(convertStringsToChars(inputpath+"\"+newfilename(i)));
        [connectivity_matrix, intersection_node_indices] = extract_connectivity(parsed_osm);
        intersection_nodes = get_unique_node_xy(parsed_osm, intersection_node_indices);
        adjacencyMatrix = or(connectivity_matrix, connectivity_matrix.');

        m = matfile(outputpath+"\"+newfilename(i)+".mat",'writable',true);
        m.connectivity_matrix = connectivity_matrix;
        m.intersection_node_indices = intersection_node_indices;
        m.intersection_nodes = intersection_nodes;
        m.adjacencyMatrix = adjacencyMatrix;

    end
    tocBytes(gcp)
end