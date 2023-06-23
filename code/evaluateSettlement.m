function [] = evaluateSettlement(D,M,Y)

    % Load mass movement susceptibility map
    [p, pR] = readgeoraster("results\mapSusceptibility\array_prob_adj_50th_"+string(Y)+'_'+string(M)+'_'+string(D)+".tif"); %1550x1195
    [p2,~] = mapresize(p,pR,20);
    clear p

    % Load settlement label
    [s_ID, ~] = readgeoraster("data\settlement\settlement2022_ID.tif");
    
    countyID = [1 3 4 5 6 7 8 10 11 29]';
    % County 1 - Agder - 369k-by-369k-sparse-matrix - 11min
    % County 3 - Troms og Finnmark - 388k-by-388k-sparse-matrix - 14min
    % County 4 - Møre og Romsdal - 286k-by-286k-sparse-matrix - 6.5min
    % County 5 - Vestfold og Telemark - 455k-by-455k-sparse-matrix - 17.5min
    % County 6 - Trøndelag - 640k-by-640k-sparse-matrix - 33.5min
    % County 7 - Rogaland - 275k-by-275k-sparse-matrix - 6.8min
    % County 8 - Innlandet - 1151k-by-1151k-sparse-matrix - 1hr 48min
    % County 10 - Nordland - 383k-by-383k-sparse-matrix - 11.4min
    % County 11 - Vestland - 562k-by-562k-sparse-matrix - 26.8min
    % County 29 - Oslo and Viken - 1010k-by-1010k-sparse-matrix - 1hr 17min

    % Create adjacency matrix for network and settlement map
    % [] = createADJsimplex(county,countyID); % optional - takes long hours (big data)
    for county = 1:10
    
        % load adjacency matrix for network and settlement map
        load("data\mask\adjacency_files\county"+string(countyID(county))+".mat",...
            "rsm_adjidx","rsm_adjrow","rsm_adjcol","rsm_adjarray")
        G = graph(rsm_adjarray);     
        
        % extract the settlement node idx and 
        % [idx_i,ngroup_setID_size,ngroup_setID] = extractSettlementNodeIdx(s_ID,county,countyID,rsm_adjidx); % optional
        load("data\mask\settlement_node_idx\county"+string(countyID(county))+"_settlement_idx.mat",...
            "idx_i","ngroup_setID_size","ngroup_setID")

        
        % construct the new graph adjacency matrix
        rsm_adjarray_settlement = zeros(ngroup_setID_size,ngroup_setID_size);
        rsm_adjarray_settlement_prob = rsm_adjarray_settlement; 
        for i = 1:ngroup_setID_size 

            j = 1:i;
            [tr,d,~] = shortestpathtree(G, idx_i(i), idx_i(j),'OutputForm','cell');
            ind = sub2ind(size(rsm_adjarray_settlement),repelem(i,i),j);
            
            rsm_adjarray_settlement(ind) = (d==Inf).*0 + (d~=Inf).*d;
            temp = cellfun(@(x) max(x),cellfun(@(x) p2(x),cellfun(@(x) rsm_adjidx(x), ...
                tr,'UniformOutput',false),'UniformOutput',false),'UniformOutput',false);
            tempind = cellfun('isempty',temp);
            temp(tempind) = {single(0.000001)};
            rsm_adjarray_settlement_prob(ind) = (d==Inf).*1 + (d~=Inf).*cell2mat(temp)';

        end
        rsm_adjarray_settlement = rsm_adjarray_settlement - diag(diag(rsm_adjarray_settlement));
        rsm_adjarray_settlement_prob = rsm_adjarray_settlement_prob - diag(diag(rsm_adjarray_settlement_prob));
        rsm_adjarray_settlement_sym = rsm_adjarray_settlement'+triu(rsm_adjarray_settlement',1)';
        rsm_adjarray_settlement_sym(isnan(rsm_adjarray_settlement_sym))=0;
        rsm_adjarray_settlement_prob_sym = rsm_adjarray_settlement_prob'+triu(rsm_adjarray_settlement_prob',1)';

        % determine the minimum distance d_min in such a way that the
        % original adjacency matrix (connectivity matrix) remains unchanged
        dist_conncomp = sort(unique(nonzeros(triu(rsm_adjarray_settlement_sym))),'descend');
        for i = 1:numel(dist_conncomp)
            adj_temp2 = rsm_adjarray_settlement_sym.*(rsm_adjarray_settlement_sym<dist_conncomp(i,1));
            dist_conncomp(i,2) = numel(unique(conncomp(graph(adj_temp2))));
        end
        orig_conncomp = numel(unique(conncomp(graph(rsm_adjarray_settlement_sym))));
        d_min = min(dist_conncomp((dist_conncomp(:,2)==orig_conncomp),1));

        % modify the original adjacency matrix (connectivity matrix) using the d_min
        rsm_adjarray_settlement_sym = rsm_adjarray_settlement_sym.*(rsm_adjarray_settlement_sym<d_min);
        
        % the original adjacency matrix (connectivity matrix) uses distances
        % transform this in such a way that 1 corresponds to stronger
        % connection, wherein:
        % high absolute value (close to 1) means closer
        % low absolute value (close to 0) means no edge or no
        rsm_adjarray_settlement_sym = ( 1 - rsm_adjarray_settlement_sym./max(max(rsm_adjarray_settlement_sym)) ) ...
                                        .*(rsm_adjarray_settlement_sym>0);

        % perform spectral graph clustering with a purpose of knowing the
        % number of connected subcomponents given increasing threshold
        % cutoff value
        conn = [];
        for i = 1:1000

            % modify the adjacencey matrix given cutoff value
            rsm_adjarray_input = rsm_adjarray_settlement_sym.*(rsm_adjarray_settlement_prob_sym<((1000-i)/1000));

            % alternative matlab simple operation
            % [bins, binsizes] = conncomp(graph(rsm_adjarray_input));
            % conn = [conn; binsizes(bins)];
        
            % spectral graph clustering
            degree_input = diag(sum(rsm_adjarray_input,1));
            laplacian_input = degree_input - rsm_adjarray_input;
            [V_m_new,D_m_new,flag_m_new] = eigs(laplacian_input,ngroup_setID_size,1e-2);
            kidx = find(round(diag(D_m_new),5)==0);
            x = kmeans(V_m_new(:,kidx),numel(kidx));
            uv = unique(x);
            n  = histc(x,uv);
            conn = [conn; changem(x,n,uv)'];

        end
        
        % inter-exposure probability of single (n=1) settlement isolation 
        % due to the probability of road obstruction
        n = 1;
        inter_prob = max((conn == n).*(((1000-(1:1000))./1000)'));
        inter_prob(find(conn(1,:) == 1)) = 9; %invalid probability - to distinguish, assign 9

        % intra-exposure probability of due to its susceptibility from mass movement
        intra_prob = zeros(ngroup_setID_size,1);
        for i = 1:ngroup_setID_size
            intra_prob(i,1) = mean(full(p2(find(s_ID==ngroup_setID(i)))));
        end
        
        % save
        settlement_shp = readgeotable("data\settlement\settlement2022.shp");
        rows = ismember(settlement_shp.OBJECTID,ngroup_setID);
        sub = settlement_shp(rows,:);
        sub.inter_prop = inter_prob';
        sub.intra_prob = intra_prob;
        shapewrite(sub,"results\evaluateSettlement\vector\settlement_county"+string(countyID(county))...
            +"_"+string(Y)+'_'+string(M)+'_'+string(D)+".shp")
       
        % postprocess summary - incorporate population info to levels of
        % probability being exposed 
        uniq_municipality = unique(sub.tettstedna);
        inter_prob_municipality = zeros(numel(uniq_municipality),1);
        intra_prob_municipality = inter_prob_municipality;
        population_municipality = inter_prob_municipality;
        for i = 1:numel(uniq_municipality)
            temp = sub.totalbefol(ismember(sub.tettstedna,uniq_municipality(i)));
            population_municipality(i,1) = temp(1);
            intra_prob_municipality(i,1) = mean(sub.intra_prob(ismember(sub.tettstedna,uniq_municipality(i))));
            dist_conncomp = sub.inter_prop(ismember(sub.tettstedna,uniq_municipality(i)));
            inter_prob_municipality(i,1) = mean(dist_conncomp(dist_conncomp ~= 9));
        end
        T = table(uniq_municipality, intra_prob_municipality, ...
            inter_prob_municipality, population_municipality);
        writetable(T,"results\table\settlement_county"+string(countyID(county))...
            +"_"+string(Y)+'_'+string(M)+'_'+string(D)+".xlsx")
        
    end
    
   
end