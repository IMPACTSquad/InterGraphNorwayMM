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
