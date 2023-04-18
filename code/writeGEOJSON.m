load("C:\Desktop\AI4ER\03 - MRes\Easter 2023\MRes Project\" + ...
    "ArcticCCAM\data\road_network\summaryLABEL.mat", ...
    "summaryCOORDS","centroid")
temp = unique([summaryCOORDS(:,1) centroid],"rows");
length = 350; % meters
diffdeg = (length/2)*(0.000001/0.11);
temp(:,4) = temp(:,2) - diffdeg; %min_x
temp(:,5) = temp(:,3) - diffdeg; %min_y
temp(:,6) = temp(:,2) + diffdeg; %max_x
temp(:,7) = temp(:,3) + diffdeg; %max_y

output_path = "C:\Desktop\AI4ER\03 - MRes\Easter 2023\MRes Project\" + ...
    "OneDrive - University of Cambridge\geoJSON\";
for i = 1:numel(temp(:,1))
    disp(i)
    tic
    copyfile(output_path+'template.json', ...
             convertStringsToChars(output_path+num2str(temp(i,1))+"_gee.json"));
    fid  = fopen(convertStringsToChars(output_path+num2str(temp(i,1))+"_gee.json"),'r');
    f = fread(fid,'*char')';
    fclose(fid);
    f = strrep(f,'min_x',convertStringsToChars(num2str(temp(i,4))));
    f = strrep(f,'min_y',convertStringsToChars(num2str(temp(i,5))));
    f = strrep(f,'max_x',convertStringsToChars(num2str(temp(i,6))));
    f = strrep(f,'max_y',convertStringsToChars(num2str(temp(i,7))));
    fid  = fopen(convertStringsToChars(output_path+num2str(temp(i,1))+"_gee.json"),'w');
    fprintf(fid,'%s',f);
    fclose(fid);
    toc
end
