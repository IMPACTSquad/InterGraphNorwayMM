%% get LABEL
clear all
clc
inputpath = "C:\Desktop\AI4ER\03 - MRes\Easter 2023\MRes Project\OneDrive - University of Cambridge\graphData";
outputpath = "C:\Desktop\AI4ER\03 - MRes\Easter 2023\MRes Project\ArcticCCAM\data\road_network";
contents = struct2table(dir(inputpath));
filename = string(contents.name(find(contents.isdir==0)));

landslide_incidents = readtable("data\landslide_incidents\landslide_incidents_27341_since20150623_alongroad_norwayonly.xlsx");
summaryCOORDS = [];
centroid = [];
distance = [];
binarylabel = [];
contlabel = [];
date = [];
lstype = [];

tic
for i = 1:numel(filename)
    temp = convertStringsToChars(filename(i));
    temp_fid2 = str2num(temp(4:end-23));
    load(inputpath+"\"+filename(i))
    for j = 1:numel(intersection_node_indices) 
        summaryCOORDS = [      summaryCOORDS;...
                               temp_fid2      ...
                               intersection_node_indices(j)...
                               intersection_nodes.xys(1,j) ...
                               intersection_nodes.xys(2,j) ];
        centroid = [           centroid; ...
                               landslide_incidents.x(landslide_incidents.fid2==temp_fid2) ...
                               landslide_incidents.y(landslide_incidents.fid2==temp_fid2)];
        dx = 1000.*deg2km(abs(intersection_nodes.xys(1,j)-landslide_incidents.x(landslide_incidents.fid2==temp_fid2)));
        dy = 1000.*deg2km(abs(intersection_nodes.xys(2,j)-landslide_incidents.y(landslide_incidents.fid2==temp_fid2)));
        distance = [           distance; ...
                               sqrt(dx.*dx+dy.*dy)];
        binarylabel = [        binarylabel; ...
                               sqrt(dx.*dx+dy.*dy)<=85 ];
        contlabel  = [         contlabel; ...
                               (sqrt(dx.*dx+dy.*dy)<=85).*1 + ...
                               (sqrt(dx.*dx+dy.*dy)>=385).*0 + ...
                               ((sqrt(dx.*dx+dy.*dy)<385)&(sqrt(dx.*dx+dy.*dy)>85)).*(385-sqrt(dx.*dx+dy.*dy))./300];
        date = [               date;
                               landslide_incidents.YYYY(landslide_incidents.fid2==temp_fid2) ...
                               landslide_incidents.MM(landslide_incidents.fid2==temp_fid2) ...
                               landslide_incidents.DD(landslide_incidents.fid2==temp_fid2) ...
                               landslide_incidents.H(landslide_incidents.fid2==temp_fid2) ...
                               landslide_incidents.M(landslide_incidents.fid2==temp_fid2) ...
                               landslide_incidents.S(landslide_incidents.fid2==temp_fid2)];
        lstype = [             lstype; ...
                               landslide_incidents.lstype_ind(landslide_incidents.fid2==temp_fid2)];

    end
    disp(i/numel(filename)*100)
    toc
end

m = matfile(outputpath+"\"+"summaryLABEL.mat",'writable',true);
m.summaryCOORDS = summaryCOORDS;
m.centroid = centroid;
m.distance = distance;
m.binarylabel = binarylabel;
m.contlabel = contlabel;
m.date = date;
m.lstype = lstype;