function [] = mapSusceptibility(D,M,Y)

    % Load time-sensitive features
    tempath_swe   = "results\custom\seNorgeSnow\swe\swe_"   +Y;
    tempath_sd    = "results\custom\seNorgeSnow\sd\sd_"     +Y;
    tempath_fsw   = "results\custom\seNorgeSnow\fsw\fsw_"   +Y;
    tempath_rrtg  = "results\custom\seNorge\seNorge_"       +Y;
    dayCount = daysdif( datetime(Y,1,1),...
                        datetime(Y,M,D) )+1;
    array_swe = rot90(ncread(tempath_swe,"snow_water_equivalent",[1 1 dayCount],[Inf Inf 1]));
    array_sd = rot90(ncread(tempath_sd,"snow_depth",[1 1 dayCount],[Inf Inf 1]));
    array_fsw = rot90(ncread(tempath_fsw,"snow_amount",[1 1 dayCount],[Inf Inf 1]));
    array_rr = rot90(fliplr(ncread(tempath_rrtg,"rr",[1 1 dayCount],[Inf Inf 1])));
    array_tg = rot90(fliplr(ncread(tempath_rrtg,"tg",[1 1 dayCount],[Inf Inf 1])));
    [array_steepness, ~] = readgeoraster("data\feature\steepness_1000m_resampled50m.tif");

    % Load lithology, land cover, and slope data
    p = readtable('data\feature\grid_IDs_and_features.xlsx');

    % Load valid grid ID
    validGRIDid = readtable('data\feature\valid_grid_IDs.xlsx').validGRIDid;
    validGRIDid_x = readtable('data\feature\valid_grid_IDs.xlsx').validGRIDid_x;
    validGRIDid_y = readtable('data\feature\valid_grid_IDs.xlsx').validGRIDid_y;

    % Load geographical information limits
    [LSrate, nR] = readgeoraster("data\feature\label_counts.tif");
    x_min = nR.XWorldLimits(1);
    y_max = nR.YWorldLimits(2);

    % Get the indices for each valid grid ID
    % and remove nan (invalid) data
    col = ceil((validGRIDid_x-x_min)/1000);
    row = ceil((y_max-validGRIDid_y)/1000);
    indF = sub2ind(size(LSrate),row,col);
    temp = cat( 2, ...
                array_fsw(indF), ...
                array_rr(indF), ...
                array_sd(indF), ...
                array_swe(indF), ...
                array_steepness(indF) );
    idxNotNAN = find(   ~isnan(temp(:,1)) & ...
                        ~isnan(temp(:,2)) & ...
                        ~isnan(temp(:,3)) & ...
                        ~isnan(temp(:,4)) & ...
                        ~isnan(temp(:,5)) );
    rng(1)
    idx = idxNotNAN(randperm(numel(idxNotNAN)));
    Nuniverse = numel(idx); % number of valid GRID ids for this particular date

    % Initialize the smaller datasets of 1000 in length
    Aspatial = cell(ceil(Nuniverse/1000),1);
    Aattribute = cell(ceil(Nuniverse/1000),1);
    feature = cell(ceil(Nuniverse/1000),1);

    % Prepare data
    parfor i = 1:ceil(Nuniverse/1000)
        if i ~= ceil(Nuniverse/1000)

            % construct neighborhood-aware adjacency matrix
            xa = repmat(single(validGRIDid_x(idx(((i-1)*1000+1):(1000*i)))),[1 1000]);
            ya = repmat(single(validGRIDid_y(idx(((i-1)*1000+1):(1000*i)))),[1 1000]);
            Aspatial{i,1} = sparse((sqrt((xa-xa').^2+(ya-ya').^2)) <= 12000);
            
            % construct attribute-aware adjacency matrix
            sb = repmat(    ...
                            p.lithology( arrayfun( @(x)( find(p.id_grid==x) ), single(validGRIDid(idx(((i-1)*1000+1):(1000*i)))) ) ), ...
                            [1 1000]);
            sc = repmat(    ...
                            p.landcover( arrayfun( @(x)( find(p.id_grid==x) ), single(validGRIDid(idx(((i-1)*1000+1):(1000*i)))) ) ), ...
                            [1 1000]);
            sd = repmat(    ...
                            p.slope( arrayfun( @(x)( find(p.id_grid==x) ), single(validGRIDid(idx(((i-1)*1000+1):(1000*i)))) ) ), ...
                            [1 1000]);
            Aattribute{i,1} = ( ( (sb.*sb') + (sc.*sc') + (sd.*sd') ) ./ ...
                    ( sqrt(sb.^2+sc.^2+sd.^2) .* sqrt(sb'.^2+sc'.^2+sd'.^2) ) ) > 0.5 ;
            
            % obtain the features
            coordX = single(validGRIDid_x(idx(((i-1)*1000+1):(1000*i))));
            coordY = single(validGRIDid_y(idx(((i-1)*1000+1):(1000*i))));
            col = ceil((coordX-x_min)/1000);
            row = ceil((y_max-coordY)/1000);
            indF = sub2ind(size(LSrate),row,col);
            feature{i,1} = cat( 2, ...
                                p.susceptibility( arrayfun( @(x)( find(p.id_grid==x) ), single(validGRIDid(idx(((i-1)*1000+1):(1000*i)))) ) ), ...
                                array_steepness(indF), ...
                                array_rr(indF), ...
                                array_tg(indF) + 273.15, ...
                                array_sd(indF), ...
                                array_swe(indF), ...
                                array_fsw(indF), ...
                                p.slope( arrayfun( @(x)( find(p.id_grid==x) ), single(validGRIDid(idx(((i-1)*1000+1):(1000*i)))) ) ), ...
                                p.lithology( arrayfun( @(x)( find(p.id_grid==x) ), single(validGRIDid(idx(((i-1)*1000+1):(1000*i)))) ) ), ...
                                p.landcover( arrayfun( @(x)( find(p.id_grid==x) ), single(validGRIDid(idx(((i-1)*1000+1):(1000*i)))) ) ) );
    
        elseif i == ceil(Nuniverse/1000)

            % construct neighborhood-aware adjacency matrix
            xa = repmat(single(validGRIDid_x(idx(((i-1)*1000+1):end))),[1 numel(idx(((i-1)*1000+1):end))]);
            ya = repmat(single(validGRIDid_y(idx(((i-1)*1000+1):end))),[1 numel(idx(((i-1)*1000+1):end))]);
            Aspatial{i,1} = sparse((sqrt((xa-xa').^2+(ya-ya').^2)) <= 12000);
    
            % construct attribute-aware adjacency matrix
            sb = repmat(    ...
                            p.lithology( arrayfun( @(x)( find(p.id_grid==x) ), single(validGRIDid(idx(((i-1)*1000+1):end))) ) ), ...
                            [1 numel(idx(((i-1)*1000+1):end))]);
            sc = repmat(    ...
                            p.landcover( arrayfun( @(x)( find(p.id_grid==x) ), single(validGRIDid(idx(((i-1)*1000+1):end))) ) ), ...
                            [1 numel(idx(((i-1)*1000+1):end))]);
            sd = repmat(    ...
                            p.slope( arrayfun( @(x)( find(p.id_grid==x) ), single(validGRIDid(idx(((i-1)*1000+1):end))) ) ), ...
                            [1 numel(idx(((i-1)*1000+1):end))]);
            Aattribute{i,1} = ( ( (sb.*sb') + (sc.*sc') + (sd.*sd') ) ./ ...
                    ( sqrt(sb.^2+sc.^2+sd.^2) .* sqrt(sb'.^2+sc'.^2+sd'.^2) ) ) > 0.5 ;
    
            % obtain the features
            coordX = single(validGRIDid_x(idx(((i-1)*1000+1):end)));
            coordY = single(validGRIDid_y(idx(((i-1)*1000+1):end)));
            col = ceil((coordX-x_min)/1000);
            row = ceil((y_max-coordY)/1000);
            indF = sub2ind(size(LSrate),row,col);
            feature{i,1} = cat( 2, ...
                                p.susceptibility( arrayfun( @(x)( find(p.id_grid==x) ), single(validGRIDid(idx(((i-1)*1000+1):end))) ) ), ...                        
                                array_steepness(indF), ...
                                array_rr(indF), ...
                                array_tg(indF) + 273.15, ...
                                array_sd(indF), ...
                                array_swe(indF), ...
                                array_fsw(indF), ...
                                p.slope( arrayfun( @(x)( find(p.id_grid==x) ), single(validGRIDid(idx(((i-1)*1000+1):end))) ) ), ...
                                p.lithology( arrayfun( @(x)( find(p.id_grid==x) ), single(validGRIDid(idx(((i-1)*1000+1):end))) ) ), ...
                                p.landcover( arrayfun( @(x)( find(p.id_grid==x) ), single(validGRIDid(idx(((i-1)*1000+1):end))) ) ) );
        end
    end
    
    % apply the trained model
    MapValues = cell(ceil(Nuniverse/1000),32);
    MapValues_adjusted = cell(ceil(Nuniverse/1000),32);
    MapValues_summary = cell(ceil(Nuniverse/1000),1);
    MapValues_adjusted_summary = cell(ceil(Nuniverse/1000),1);
    MapValues_std_summary = cell(ceil(Nuniverse/1000),1);
    MapValues_std_adjusted_summary = cell(ceil(Nuniverse/1000),1);
    load("results\selectGNN\selectGNN_results.mat",'optimal_threshold','selection')
    h.feature = [   1 1 1 1 1 1 0 1 0 0;...
                        1 1 1 1 1 0 1 1 0 0;...
                        1 1 1 1 1 0 0 1 1 0;...
                        1 1 1 1 1 0 0 1 0 1;...
                        1 1 1 1 0 1 1 1 0 0;...
                        1 1 1 1 0 1 0 1 1 0;...
                        1 1 1 1 0 1 0 1 0 1;...
                        1 1 1 1 0 0 1 1 1 0;...
                        1 1 1 1 0 0 1 1 0 1;...
                        1 1 1 1 0 0 0 1 1 1;...
                        1 1 0 1 0 1 0 1 1 1]; %Feature Selection
    for iM = 1:32
        temp2 = load("results\applyGNN\multiHyperparameter_final_opt3c_"+string(selection(iM,2))+".mat", ...
                    "parameter_map","muX_map","sigsqX_map");
        parameters = temp2.parameter_map{iM,selection(iM,1)};
        muX = temp2.muX_map{iM,selection(iM,1)};
        sigsqX = temp2.sigsqX_map{iM,selection(iM,1)};
        parfor iN = 1:ceil(Nuniverse/1000)
            fdata = (feature{iN,1}(:,find(h.feature(selection(iM,1),:)==1))- muX)./sqrt(sigsqX);
            Adata = full(Aattribute{iN,1} & Aspatial{iN,1});
            AdataNorm = normalizeAdjacency(Adata);
            [Ydata,~,~,~] = model(parameters,fdata,AdataNorm);
            Ydata = extractdata(Ydata(:,2));
            MapValues{iN,iM} = Ydata;  
            MapValues_adjusted{iN,iM} = (Ydata<optimal_threshold).*0.5.*(Ydata./optimal_threshold) + ...
                                        (Ydata>=optimal_threshold).*(0.5+0.5.*(Ydata-optimal_threshold)./(1-optimal_threshold));
        end
        toc
    end
    for iN = 1:ceil(Nuniverse/1000)
        temp_val = [];
        temp_adj = [];
        for iM = 1:32
            temp_val = [temp_val; MapValues{iN,iM}'];
            temp_adj = [temp_adj; MapValues_adjusted{iN,iM}'];
        end
        MapValues_summary{iN,1} = sum(temp_val',2)./32;
        MapValues_adjusted_summary{iN,1} = sum(temp_adj',2)./32;
        MapValues_std_summary{iN,1} = sqrt(var(temp_val))';
        MapValues_std_adjusted_summary{iN,1} = sqrt(var(temp_adj))';
    end
    
    %% export images
    geotiffwrite("results\mapSusceptibility\array_fsw_"+string(Y)+'_'+string(M)+'_'+string(D)+".tif",array_fsw,nR,'CoordRefSysCode',25833);
    geotiffwrite("results\mapSusceptibility\array_rr_"+string(Y)+'_'+string(M)+'_'+string(D)+".tif",array_rr,nR,'CoordRefSysCode',25833);
    geotiffwrite("results\mapSusceptibility\array_tg_"+string(Y)+'_'+string(M)+'_'+string(D)+".tif",array_tg,nR,'CoordRefSysCode',25833);
    geotiffwrite("results\mapSusceptibility\array_sd_"+string(Y)+'_'+string(M)+'_'+string(D)+".tif",array_sd,nR,'CoordRefSysCode',25833);
    geotiffwrite("results\mapSusceptibility\array_swe_"+string(Y)+'_'+string(M)+'_'+string(D)+".tif",array_swe,nR,'CoordRefSysCode',25833);
    array_prob_val = 0.*LSrate;
    array_prob_val = single(array_prob_val(:));
    array_prob_adj = array_prob_val;
    array_prob_val_std = array_prob_val;
    array_prob_adj_std = array_prob_val;
    for i = 1:ceil(Nuniverse/1000)
        if i ~= ceil(Nuniverse/1000)
            coordX = single(validGRIDid_x(idx(((i-1)*1000+1):(1000*i))));
            coordY = single(validGRIDid_y(idx(((i-1)*1000+1):(1000*i))));
            col = ceil((coordX-x_min)/1000);
            row = ceil((y_max-coordY)/1000);
            indF = sub2ind(size(LSrate),row,col);
            array_prob_val(indF) = MapValues_summary{i,1};
            array_prob_val_std(indF) = MapValues_std_summary{i,1};
            array_prob_adj(indF) = MapValues_adjusted_summary{i,1};
            array_prob_adj_std(indF) = MapValues_std_adjusted_summary{i,1};
        elseif i == ceil(Nuniverse/1000)
            coordX = single(validGRIDid_x(idx(((i-1)*1000+1):end)));
            coordY = single(validGRIDid_y(idx(((i-1)*1000+1):end)));
            col = ceil((coordX-x_min)/1000);
            row = ceil((y_max-coordY)/1000);
            indF = sub2ind(size(LSrate),row,col);
            array_prob_val(indF) = MapValues_summary{i,1};
            array_prob_val_std(indF) = MapValues_std_summary{i,1};
            array_prob_adj(indF) = MapValues_adjusted_summary{i,1};
            array_prob_adj_std(indF) = MapValues_std_adjusted_summary{i,1};
        end
    end
    array_prob_val = reshape(array_prob_val,size(LSrate));
    array_prob_val_std = reshape(array_prob_val_std,size(LSrate));
    array_prob_adj = reshape(array_prob_adj,size(LSrate));
    array_prob_adj_std = reshape(array_prob_adj_std,size(LSrate));
    geotiffwrite("results\mapSusceptibility\array_prob_adj_std_"+string(Y)+'_'+string(M)+'_'+string(D)+".tif",...
        imfilter(array_prob_adj_std, fspecial('disk', 3)),nR,'CoordRefSysCode',25833);
    geotiffwrite("results\mapSusceptibility\array_prob_adj_50th_"+string(Y)+'_'+string(M)+'_'+string(D)+".tif",...
        imfilter(array_prob_adj, fspecial('disk', 3)),nR,'CoordRefSysCode',25833);
    geotiffwrite("results\mapSusceptibility\array_prob_adj_84th_"+string(Y)+'_'+string(M)+'_'+string(D)+".tif",...
        imfilter(array_prob_adj, fspecial('disk', 3))+imfilter(array_prob_adj_std, fspecial('disk', 3)),nR,'CoordRefSysCode',25833);
    
    save('results\mapSusceptibility\mapSusceptibility_'+string(Y)+'_'+string(M)+'_'+string(D)+'.mat',...
        "array_prob_val","array_prob_val_std","array_prob_adj","array_prob_adj_std",...
        "idx","Aspatial","Aattribute","feature","MapValues","MapValues_adjusted",...
        "MapValues_summary","MapValues_adjusted_summary",...
        "MapValues_std_summary","MapValues_std_adjusted_summary")

end