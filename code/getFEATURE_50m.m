clear, clc, close
tic

%% load the rasterized network data
[n, nR] = readgeoraster(['C:\Desktop\AI4ER\03 - MRes\Easter 2023\' ...
    'MRes Project\resolution_study\railyway_rasterized_50m.tif']);
n = sparse(1.*(n>0)); %binary: 0 - no railway/road, 1 - with railway/road
x_min = nR.XWorldLimits(1);
x_max = nR.XWorldLimits(2);
y_min = nR.YWorldLimits(1);
y_max = nR.YWorldLimits(2);
res = 50; %50m resolution (based on the quality of steepness map)
toc
disp('Rasterized Network System Loaded')

%% load the location of landslide incidents
ls = readtable(['C:\Desktop\AI4ER\03 - MRes\Easter 2023\' ...
    'MRes Project\ArcticCCAM\data\landslide_incidents\' ...
    'landslide_incidents_1747_near_railway_addXY.xlsx']);
toc
disp('Landslide Incident Information Loaded')

%% steepness landslide

[steep, steepR] = readgeoraster("C:\Desktop\AI4ER\03 - MRes\Easter 2023" + ...
    "\MRes Project\ArcticCCAM\data\steepness_landslide\steepness_landslide_50m.tif");

steep_R = double(steep(:,:,1).*uint8(full(n)));
steep_G = double(steep(:,:,2).*uint8(full(n)));
steep_B = double(steep(:,:,3).*uint8(full(n)));
steep_value =   (steep_R==255 & steep_G==255 & steep_B==255).*1.5 + ...
                (steep_R==211 & steep_G==255 & steep_B==190).*4.5 + ...
                (steep_R==38 & steep_G==115 & steep_B==0).*8 + ...
                (steep_R==170 & steep_G==255 & steep_B==0).*13 + ...
                (steep_R==230 & steep_G==152 & steep_B==0).*20.5 + ...
                (steep_R==230 & steep_G==76 & steep_B==0).*35.5 + ...
                (steep_R==168 & steep_G==0 & steep_B==0).*68;
steep_value = sparse(steep_value);
clear steep_R steep_G steep_B steep n
toc
disp('Steepness Map Loaded')

load(['C:\Desktop\AI4ER\03 - MRes\Easter 2023\MRes Project\' ...
    'ArcticCCAM\data\landslide_incidents\' ...
    'validindices_equallyrepresented.mat'])
outputpath = ['C:\Desktop\AI4ER\03 - MRes\Easter 2023\MRes Project\' ...
    'ArcticCCAM\data\steepness_landslide\equallyrepresented'];
adjpath = ['C:\Desktop\AI4ER\03 - MRes\Easter 2023\MRes Project\' ...
    'ArcticCCAM\data\road_network\graphData_railway_equallyrepresented'];
for k = 1:numel(fid_f)
    tic
    disp(k*100/numel(fid_f))
    load(strcat(adjpath+"\"+string(fid_f(k))))
    steepness_sub = steep_value(int64(it):int64(ib),int64(il):int64(ir));
    ind = sub2ind([size(steepness_sub,1) size(steepness_sub,2)],row,col);
    steepness = steepness_sub(ind);
    m = matfile(outputpath+"\"+string(fid_f(k))+"steepness.mat",'writable',true);
    m.ind = ind;
    m.steepness_sub = steepness_sub;
    m.steepness = steepness;
    toc
end
toc

%% seNorge2018, seNorgeSnow, and MetNordic 
clear, clc, close
tic
load(['C:\Desktop\AI4ER\03 - MRes\Easter 2023\MRes Project\' ...
    'ArcticCCAM\data\landslide_incidents\' ...
    'validindices_equallyrepresented.mat'])

% get location indices and save initial mat files
metpath = ['C:\Desktop\AI4ER\03 - MRes\Easter 2023\MRes Project\' ...
    'ArcticCCAM\data\meteorological_data\equallyrepresented'];

seNorge = struct();
seNorge.x_bins = 1195;
seNorge.y_bins = 1550;
seNorge.x_min = -75000;
seNorge.y_min = 6450000;
seNorge.x_max = 1120000;
seNorge.y_max = 8000000;

seNorgeSnow = struct();
seNorgeSnow.x_bins = 1195;
seNorgeSnow.y_bins = 1550;
seNorgeSnow.x_min = -75500;
seNorgeSnow.y_min = 6449500;
seNorgeSnow.x_max = 1119500;
seNorgeSnow.y_max = 7999500;

metNordic = struct();
metNordic.x_bins = 1796;
metNordic.y_bins = 2321;
metNordic.x_min = 500058.0371462452 - metNordic.x_bins/2*1000;
metNordic.y_min = 7042651.8031376097 - metNordic.y_bins/2*1000;
metNordic.x_max = 500058.0371462452 + metNordic.x_bins/2*1000;
metNordic.y_max = 7042651.8031376097 + metNordic.y_bins/2*1000;


adjpath = ['C:\Desktop\AI4ER\03 - MRes\Easter 2023\MRes Project\' ...
    'ArcticCCAM\data\road_network\graphData_railway_equallyrepresented'];
for i = 1:numel(fid_f)
    tic
    disp(i*100/numel(fid_f))
    load(strcat(adjpath+"\"+string(fid_f(i))))

    x_coord = x_min + res./2 + (il-1).*res + (col-1).*res;
    y_coord = y_max - res./2 - (it-1).*res - (row-1).*res; 
    seNorge_row = ceil((seNorge.y_max-y_coord)./(seNorge.y_max-seNorge.y_min).*seNorge.y_bins);
    seNorge_col = ceil((x_coord-seNorge.x_min)./(seNorge.x_max-seNorge.x_min).*seNorge.x_bins);
    seNorgeSnow_row = ceil((seNorgeSnow.y_max-y_coord)./(seNorgeSnow.y_max-seNorgeSnow.y_min).*seNorgeSnow.y_bins);
    seNorgeSnow_col = ceil((x_coord-seNorgeSnow.x_min)./(seNorgeSnow.x_max-seNorgeSnow.x_min).*seNorgeSnow.x_bins);
    metNordic_row = ceil((metNordic.y_max-y_coord)./(metNordic.y_max-metNordic.y_min).*metNordic.y_bins);
    metNordic_col = ceil((x_coord-metNordic.x_min)./(metNordic.x_max-metNordic.x_min).*metNordic.x_bins);
    
    m = matfile(metpath+"\"+string(fid_f(i))+"met.mat",'writable',true);
    m.seNorge_row = seNorge_row;
    m.seNorge_col = seNorge_col;
    m.seNorgeSnow_row = seNorgeSnow_row;
    m.seNorgeSnow_col = seNorgeSnow_col;
    m.metNordic_row = metNordic_row;
    m.metNordic_col = metNordic_col;

    toc
end

% extract data seNorge
seNorge.OpenDAP_file_path = "https://thredds.met.no/thredds/dodsC/" + ...
    "senorge/seNorge_2018/Archive/seNorge2018_";
ls = readtable(['C:\Desktop\AI4ER\03 - MRes\Easter 2023\' ...
    'MRes Project\ArcticCCAM\data\landslide_incidents\' ...
    'landslide_incidents_1747_near_railway_addXY.xlsx']);
n_past = 10;
tic
parfor i = 1:numel(fid_f)

    info = load(metpath+"\"+string(fid_f(i))+"met.mat"); %row, col
    i0 = find(ls.fid==fid_f(i));

    tempath = seNorge.OpenDAP_file_path+ls.YYYY(i0)+".nc"; 
    dayCount = daysdif( datetime(ls.YYYY(i0),1,1),...
                        datetime(ls.YYYY(i0),ls.MM(i0),ls.DD(i0)) ...
                       )+1;

    seNorge_tg = zeros(numel(info.seNorge_row),1);
    seNorge_rr = zeros(numel(info.seNorge_row),1);

    if dayCount < 10 && ls.YYYY(i0)~=2023
        if mod(ls.YYYY(i0)-1,4)==0 %leap year
            start_p = 366 - (n_past-dayCount) + 1;
        else
            start_p = 365 - (n_past-dayCount) + 1;
        end
        tempath_p = seNorge.OpenDAP_file_path+num2str(ls.YYYY(i0)-1)+".nc";
        nctg = rot90(fliplr(ncread(tempath,"tg",[1 1 dayCount],[Inf Inf 1])));
        ncrr = rot90(fliplr(ncread(tempath,"rr",[1 1 1],[Inf Inf dayCount])));
        ncrr_p = rot90(fliplr(ncread(tempath_p,"rr",[1 1 start_p],[Inf Inf (n_past-dayCount)])));
        for j = 1:numel(info.seNorge_row)
            seNorge_tg(j,1) = nctg(info.seNorge_row(j),info.seNorge_col(j));
            seNorge_rr(j,1) = sum(sum(sum(ncrr(info.seNorge_row(j),info.seNorge_col(j),:))))+...
                sum(sum(sum(ncrr_p(info.seNorge_row(j),info.seNorge_col(j),:))));
        end
    elseif dayCount < 10 && ls.YYYY(i0)==2023
        if mod(ls.YYYY(i0)-1,4)==0 %leap year
            start_p = 366 - (n_past-dayCount) + 1 - 1;
        else
            start_p = 365 - (n_past-dayCount) + 1 - 1;
        end
        tempath_p = seNorge.OpenDAP_file_path+num2str(ls.YYYY(i0)-1)+".nc";
        nctg = rot90(fliplr(ncread(tempath,"tg",[1 1 dayCount],[Inf Inf 1])));
        ncrr = rot90(fliplr(ncread(tempath,"rr",[1 1 1],[Inf Inf dayCount])));
        ncrr_p = rot90(fliplr(ncread(tempath_p,"rr",[1 1 start_p],[Inf Inf (n_past-dayCount)])));
        for j = 1:numel(info.seNorge_row)
            seNorge_tg(j,1) = nctg(info.seNorge_row(j),info.seNorge_col(j));
            seNorge_rr(j,1) = sum(sum(sum(ncrr(info.seNorge_row(j),info.seNorge_col(j),:))))+...
                sum(sum(sum(ncrr_p(info.seNorge_row(j),info.seNorge_col(j),:))));
        end
    elseif dayCount==365 && ls.YYYY(i0)==2022
        dayCount = dayCount-1;
        nctg = rot90(fliplr(ncread(tempath,"tg",[1 1 dayCount],[Inf Inf 1])));
        ncrr = rot90(fliplr(ncread(tempath,"rr",[1 1 dayCount-(n_past-1)],[Inf Inf n_past])));
        for j = 1:numel(info.seNorge_row)
            seNorge_tg(j,1) = nctg(info.seNorge_row(j),info.seNorge_col(j));
            seNorge_rr(j,1) = sum(sum(sum(ncrr(info.seNorge_row(j),info.seNorge_col(j),:))));
        end
    else
        nctg = rot90(fliplr(ncread(tempath,"tg",[1 1 dayCount],[Inf Inf 1])));
        ncrr = rot90(fliplr(ncread(tempath,"rr",[1 1 dayCount-(n_past-1)],[Inf Inf n_past])));
        for j = 1:numel(info.seNorge_row)
            seNorge_tg(j,1) = nctg(info.seNorge_row(j),info.seNorge_col(j));
            seNorge_rr(j,1) = sum(sum(sum(ncrr(info.seNorge_row(j),info.seNorge_col(j),:))));
        end
    end

    m = matfile(metpath+"\"+string(fid_f(i))+"metseNorge.mat",'writable',true);
    m.seNorge_tg = seNorge_tg;
    m.seNorge_rr = seNorge_rr;

end
toc

% extract data seNorgeSnow
seNorgeSnow.OpenDAP_file_path_swepr = "C:\Desktop\AI4ER\03 - MRes\Easter 2023\MRes Project\seNorgeSnow\swepr\swepr_";
seNorgeSnow.OpenDAP_file_path_swe = "C:\Desktop\AI4ER\03 - MRes\Easter 2023\MRes Project\seNorgeSnow\swe\swe_";
seNorgeSnow.OpenDAP_file_path_ski = "C:\Desktop\AI4ER\03 - MRes\Easter 2023\MRes Project\seNorgeSnow\ski\ski_";
seNorgeSnow.OpenDAP_file_path_sdfsw = "C:\Desktop\AI4ER\03 - MRes\Easter 2023\MRes Project\seNorgeSnow\sdfsw\sdfsw_";
seNorgeSnow.OpenDAP_file_path_sd = "C:\Desktop\AI4ER\03 - MRes\Easter 2023\MRes Project\seNorgeSnow\sd\sd_";
seNorgeSnow.OpenDAP_file_path_qtt = "C:\Desktop\AI4ER\03 - MRes\Easter 2023\MRes Project\seNorgeSnow\qtt\qtt_";
seNorgeSnow.OpenDAP_file_path_qsw = "C:\Desktop\AI4ER\03 - MRes\Easter 2023\MRes Project\seNorgeSnow\qsw\qsw_";
seNorgeSnow.OpenDAP_file_path_lwc = "C:\Desktop\AI4ER\03 - MRes\Easter 2023\MRes Project\seNorgeSnow\lwc\lwc_";
seNorgeSnow.OpenDAP_file_path_fsw = "C:\Desktop\AI4ER\03 - MRes\Easter 2023\MRes Project\seNorgeSnow\fsw\fsw_";

load(['C:\Desktop\AI4ER\03 - MRes\Easter 2023\MRes Project\' ...
    'ArcticCCAM\data\landslide_incidents\' ...
    'validindices_equallyrepresented.mat'])

tic
indices = [];
for i = 1:numel(fid_f)
    indices = [indices; find(ls.fid==fid_f(i))];
end

uniq_year = unique(ls.YYYY(indices));
for k = 5:numel(uniq_year)
    uniq_year(k)
    tempath_swepr = seNorgeSnow.OpenDAP_file_path_swepr+uniq_year(k)+".nc";
    tempath_swe   = seNorgeSnow.OpenDAP_file_path_swe+uniq_year(k)+".nc";
    tempath_ski   = seNorgeSnow.OpenDAP_file_path_ski+uniq_year(k)+".nc";
    tempath_sdfsw = seNorgeSnow.OpenDAP_file_path_sdfsw+uniq_year(k)+".nc";
    tempath_sd    = seNorgeSnow.OpenDAP_file_path_sd+uniq_year(k)+".nc";
    tempath_qtt   = seNorgeSnow.OpenDAP_file_path_qtt+uniq_year(k)+".nc";
    tempath_qsw   = seNorgeSnow.OpenDAP_file_path_qsw+uniq_year(k)+".nc";
    tempath_lwc   = seNorgeSnow.OpenDAP_file_path_lwc+uniq_year(k)+".nc";
    tempath_fsw   = seNorgeSnow.OpenDAP_file_path_fsw+uniq_year(k)+".nc";

    YYYY_given_k = ls.YYYY(indices);
    i = find(YYYY_given_k==uniq_year(k));

    for t = 1:numel(i)

        tic
        info = load(metpath+"\"+string(fid_f(i(t)))+"met.mat"); %row, col
    
        idx = find(ls.fid == fid_f(i(t)));
        dayCount = daysdif( datetime(ls.YYYY(idx),1,1),...
                            datetime(ls.YYYY(idx),ls.MM(idx),ls.DD(idx)) ...
                           )+1;
    
        ncswepr     = rot90(ncread(tempath_swepr,"snow_water_equivalent_percentage",[1 1 dayCount],[Inf Inf 1]));
        ncswe       = rot90(ncread(tempath_swe,"snow_water_equivalent",[1 1 dayCount],[Inf Inf 1]));
        ncski       = rot90(ncread(tempath_ski,"snow_condition",[1 1 dayCount],[Inf Inf 1]));
        ncsdfsw     = rot90(ncread(tempath_sdfsw,"snow_depth",[1 1 dayCount],[Inf Inf 1]));
        ncsd        = rot90(ncread(tempath_sd,"snow_depth",[1 1 dayCount],[Inf Inf 1]));
        ncqtt       = rot90(ncread(tempath_qtt,"runoff_amount",[1 1 dayCount],[Inf Inf 1]));
        ncqsw       = rot90(ncread(tempath_qsw,"snow_melt",[1 1 dayCount],[Inf Inf 1]));
        nclwc       = rot90(ncread(tempath_lwc,"snow_liquid_water_content",[1 1 dayCount],[Inf Inf 1]));
        ncfsw       = rot90(ncread(tempath_fsw,"snow_amount",[1 1 dayCount],[Inf Inf 1]));

        seNorgeSnow_swepr = zeros(numel(info.seNorge_row),1);
        seNorgeSnow_swe   = zeros(numel(info.seNorge_row),1);
        seNorgeSnow_ski   = zeros(numel(info.seNorge_row),1);
        seNorgeSnow_sdfsw = zeros(numel(info.seNorge_row),1);
        seNorgeSnow_sd    = zeros(numel(info.seNorge_row),1);
        seNorgeSnow_qtt   = zeros(numel(info.seNorge_row),1);
        seNorgeSnow_qsw   = zeros(numel(info.seNorge_row),1);
        seNorgeSnow_lwc   = zeros(numel(info.seNorge_row),1);
        seNorgeSnow_fsw   = zeros(numel(info.seNorge_row),1);
    
        for j = 1:numel(info.seNorge_row)
            seNorgeSnow_swepr(j,1)  = ncswepr(info.seNorge_row(j),info.seNorge_col(j));
            seNorgeSnow_swe(j,1)    = ncswe(info.seNorge_row(j),info.seNorge_col(j));
            seNorgeSnow_ski(j,1)    = ncski(info.seNorge_row(j),info.seNorge_col(j));
            seNorgeSnow_sdfsw(j,1)  = ncsdfsw(info.seNorge_row(j),info.seNorge_col(j));
            seNorgeSnow_sd(j,1)     = ncsd(info.seNorge_row(j),info.seNorge_col(j));
            seNorgeSnow_qtt(j,1)    = ncqtt(info.seNorge_row(j),info.seNorge_col(j));
            seNorgeSnow_qsw(j,1)    = ncqsw(info.seNorge_row(j),info.seNorge_col(j));
            seNorgeSnow_lwc(j,1)    = nclwc(info.seNorge_row(j),info.seNorge_col(j));
            seNorgeSnow_fsw(j,1)    = ncfsw(info.seNorge_row(j),info.seNorge_col(j));
        end
        
        r = matfile(metpath+"\"+string(fid_f(i(t)))+"metseNorgeSnow.mat",'writable',true); 
        r.seNorgeSnow_swepr = seNorgeSnow_swepr;
        r.seNorgeSnow_swe = seNorgeSnow_swe;
        r.seNorgeSnow_ski = seNorgeSnow_ski;
        r.seNorgeSnow_sdfsw = seNorgeSnow_sdfsw;
        r.seNorgeSnow_sd = seNorgeSnow_sd;
        r.seNorgeSnow_qtt = seNorgeSnow_qtt;
        r.seNorgeSnow_qsw = seNorgeSnow_qsw;
        r.seNorgeSnow_lwc = seNorgeSnow_lwc;
        r.seNorgeSnow_fsw = seNorgeSnow_fsw;
        toc
    end
end
toc
