function [] = prepareData(opt1)

    if opt1 == 0

        % Load custom prepared data
        load("data\custom\feature.mat","NgridIDxGraph","fsuscep","fmx","fmy", ...
        "validGRIDid","validGRIDid_x","validGRIDid_y", ...
        "Nuniverse","Nlabels","Ngraph", ...
        "fswe","fsd","ffsw","frr","ftgC","fsteepness", ...
        "fslope", "flandcover", "flithology", "fLSrate", ...
        "-mat")

        % Export
        save("data\feature\feature.mat","NgridIDxGraph","fsuscep","fmx","fmy", ...
        "validGRIDid","validGRIDid_x","validGRIDid_y", ...
        "Nuniverse","Nlabels","Ngraph", ...
        "fswe","fsd","ffsw","frr","ftgC","fsteepness", ...
        "fslope", "flandcover", "flithology", "fLSrate", ...
        "-mat")
        
    elseif opt1 == 1

        % Load the mapping between landslide ID and grid ID
        % q has 
        % grid_id - IDs in mapping grids
        % ls_id - IDs of mass movement incidents
        % new_x - coordinates/location
        % new_y - coordinates/location
        % susceptibility - susceptibility value
        q = readtable('data\feature\grid_and_label_IDs.xlsx');
        
        % Identify the unique grid ID for all LS because landslide ID can occupy multiple grid IDs, 
        % and Determine the number of graph machine learning models
        Ngraph = floor(numel(unique(q.grid_id))/500);
        rng(100)
        uniq_gridID_LS = unique(q.grid_id);
        subLS = uniq_gridID_LS(randperm(numel(uniq_gridID_LS),Ngraph*500)');
    
        % For each graph machine learning model, partition valid ID
        % depending on those with and without labels
        p = readtable('data\feature\grid_IDs_and_features.xlsx');
        validGRIDid = readtable('data\feature\valid_grid_IDs.xlsx').validGRIDid;
        validGRIDid_x = readtable('data\feature\valid_grid_IDs.xlsx').validGRIDid_x;
        validGRIDid_y = readtable('data\feature\valid_grid_IDs.xlsx').validGRIDid_y;
        gridID_notLS = validGRIDid(~ismember(validGRIDid,q.grid_id)); % not labeled
        NgridIDxGraph = [reshape(subLS,[500 Ngraph]); ...
                     reshape(gridID_notLS(randperm(numel(gridID_notLS),500.*Ngraph)'),[500,Ngraph])];
    
        % Load histoical landslide occurrences 
        % and map projection information (nR)
        [LSrate, nR] = readgeoraster("data\feature\label_counts.tif");
        x_min = nR.XWorldLimits(1);
        y_max = nR.YWorldLimits(2);
    
        % Extract and Initialize data points for each graph machine learnig model
        fswe = 0.*NgridIDxGraph;            % snow-water equivalent
        fsd = 0.*NgridIDxGraph;             % snow depth
        ffsw = 0.*NgridIDxGraph;            % fresh snow water
        frr = 0.*NgridIDxGraph;             % rainfall
        ftgC = 0.*NgridIDxGraph;            % temperature
        fmx = 0.*NgridIDxGraph;             % longitude
        fmy = 0.*NgridIDxGraph;             % latitude
        fsteepness = 0.*NgridIDxGraph;      % steepness value
        fsuscep = 0.*NgridIDxGraph;         % ELSUS susceptibility value
        fslope = 0.*NgridIDxGraph;          % ELSUS slope category value
        flandcover = 0.*NgridIDxGraph;      % ELSUS land cover category value
        flithology = 0.*NgridIDxGraph;      % ELSUS lithology category value
        fLSrate = 0.*NgridIDxGraph;         % landslide occurrence rate
    
        % Supply feature values for IDs with mass movement observation
        load('data\feature\incident_features.mat')
        for i = 1:size(NgridIDxGraph,2)
            for j = 1:(size(NgridIDxGraph,1)/2)
                
                rng(i*1000+j)
                kk = find(q.grid_id==NgridIDxGraph(j,i));
                k = kk(randperm(numel(kk),1));
                fsuscep(j,i) = q.susceptibility(k);
                fmx(j,i) = q.new_x(k);
                fmy(j,i) = q.new_y(k);

                c = find(incident_features.fid==q.ls_id(k));
                fswe(j,i) = incident_features.swe(c);
                fsd(j,i) = incident_features.sd(c);
                ffsw(j,i) = incident_features.fsw(c);
                frr(j,i) = incident_features.rr(c);
                ftgC(j,i) = incident_features.tg(c);
                fsteepness(j,i) = incident_features.steepness(c);
                fslope(j,i) = p.slope(p.id_grid==NgridIDxGraph(j,i));
                flandcover(j,i) = p.landcover(p.id_grid==NgridIDxGraph(j,i));
                flithology(j,i) = p.lithology(p.id_grid==NgridIDxGraph(j,i));
        
        
                col = ceil((q.new_x(k)-x_min)/1000);
                row = ceil((y_max-q.new_y(k))/1000);
                fLSrate(j,i) = LSrate(row,col);
            end
        end
    
        % Supply feature values for IDs with no mass movement observation
        % Assumption: Randomly sample from many possibilities that
        % can vary by any given date in the year 2022
        % Reason: Year 2022 was used for computational effficiency (i.e.,
        % large NetCDF files) and assuming that the year 2022 with 365
        % possibilities is sufficient to capture the stochasticity of
        % non-mass-movement feature information    
        tempath_swe = "data\custom\swe_2022";
        tempath_sd = "data\custom\sd_2022";
        tempath_fsw = "data\custom\fsw_2022";
        tempath_rrtg = "data\custom\seNorge_2022";
        [steepness_array, ~] = readgeoraster("data\feature\steepness_1000m_resampled50m.tif");
        swe_array = ncread(tempath_swe,"snow_water_equivalent",[1 1 1],[Inf Inf Inf]);
        sd_array = ncread(tempath_sd,"snow_depth",[1 1 1],[Inf Inf Inf]);
        fsw_array = ncread(tempath_fsw,"snow_amount",[1 1 1],[Inf Inf Inf]);
        rr_array = ncread(tempath_rrtg,"rr",[1 1 1],[Inf Inf Inf]);
        tg_array = ncread(tempath_rrtg,"tg",[1 1 1],[Inf Inf Inf]);
        for i = 1:size(NgridIDxGraph,2)
            for j = 1:(size(NgridIDxGraph,1)/2)
                rng(i*1001+j)
                dayCount = randperm(365,1);
        
                kk = find(p.id_grid==NgridIDxGraph((size(NgridIDxGraph,1)/2)+j,i));
                k = kk(randperm(numel(kk),1));
                fsuscep((size(NgridIDxGraph,1)/2)+j,i) = p.susceptibility(k);
                fmx((size(NgridIDxGraph,1)/2)+j,i) = p.new_x(k);
                fmy((size(NgridIDxGraph,1)/2)+j,i) = p.new_y(k);
        
                col = ceil((p.new_x(k)-x_min)/1000);
                row = ceil((y_max-p.new_y(k))/1000);
                fswe((size(NgridIDxGraph,1)/2)+j,i) = swe_array(col,1550-row,dayCount);
                fsd((size(NgridIDxGraph,1)/2)+j,i) = sd_array(col,1550-row,dayCount);
                ffsw((size(NgridIDxGraph,1)/2)+j,i) = fsw_array(col,1550-row,dayCount);
                frr((size(NgridIDxGraph,1)/2)+j,i) = rr_array(col,row,dayCount);
                ftgC((size(NgridIDxGraph,1)/2)+j,i) = tg_array(col,row,dayCount);
                fsteepness((size(NgridIDxGraph,1)/2)+j,i) = steepness_array(row,col);
                fslope((size(NgridIDxGraph,1)/2)+j,i) = p.slope(p.id_grid==NgridIDxGraph((size(NgridIDxGraph,1)/2)+j,i));
                flandcover((size(NgridIDxGraph,1)/2)+j,i) = p.landcover(p.id_grid==NgridIDxGraph((size(NgridIDxGraph,1)/2)+j,i));
                flithology((size(NgridIDxGraph,1)/2)+j,i) = p.lithology(p.id_grid==NgridIDxGraph((size(NgridIDxGraph,1)/2)+j,i));
                
                fLSrate((size(NgridIDxGraph,1)/2)+j,i) = LSrate(row,col);
            end
        end 
    end

    Export
    save("data\feature\feature.mat","NgridIDxGraph","fsuscep","fmx","fmy", ...
    "validGRIDid","validGRIDid_x","validGRIDid_y", ...
    "Nuniverse","Nlabels","Ngraph", ...
    "fswe","fsd","ffsw","frr","ftgC","fsteepness", ...
    "fslope", "flandcover", "flithology", "fLSrate", ...
    "-mat")
    
end