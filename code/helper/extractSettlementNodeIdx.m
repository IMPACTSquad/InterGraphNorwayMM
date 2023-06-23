function [idx_i,ngroup_setID_size,ngroup_setID] = extractSettlementNodeIdx(s_ID,county,countyID,rsm_adjidx)
    
    % load mask
    [m, ~] = readgeoraster("data\mask\raster_maps\county"+string(countyID(county))+"_rasterized.tif");

    % initialize the a new grpah with settlements as nodes
    ngroup_setID = nonzeros(unique(s_ID.*int16(m>0)));
    ngroup_setID_size = numel(ngroup_setID);

    % get a random representative point for each settlement node group
    idx_i = zeros(ngroup_setID_size,1);
    for i = 1:ngroup_setID_size
        i*100/ngroup_setID_size,tic
        rng(i)
        temp_i = find(s_ID==ngroup_setID(i));
        temp_j = find(ismember(temp_i,rsm_adjidx)==1);
        idx_i(i) = find(rsm_adjidx==temp_i(temp_j(randi([1 numel(temp_j)]))));
        toc
    end

    save("data\mask\settlement_node_idx\county"+string(countyID(county))+"_settlement_idx.mat",...
        "idx_i","ngroup_setID_size","ngroup_setID")

end

