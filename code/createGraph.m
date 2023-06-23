function [] = createGraph(opt2)
    
    %% create spatial adjacency matrix
    if opt2 == 0
        k = 12;
        load("data\custom\graph\Aspatial_"+string(k*1000)+".mat","Aspatial","-mat")
        save("data\graph\Aspatial_"+string(k*1000)+".mat","Aspatial","-mat")
    elseif opt2 == 1
        load('data\feature\feature.mat','fmx','fmy','Ngraph')
        k = 12;
        Aspatial = cell(Ngraph,1);
        for i = 1:Ngraph
            xa = repmat(single(fmx(:,i)),[1 2*500]);
            ya = repmat(single(fmy(:,i)),[1 2*500]);
            Aspatial{i,1} = sparse((sqrt((xa-xa').^2+(ya-ya').^2)) <= 1000*k);
        end 
        save("data\graph\Aspatial_"+string(k*1000)+".mat","Aspatial","-mat")
    end

    %% create feature adjacency matrix based on different features
    if opt2 == 0
        load("data\feature\feature.mat","Ngraph");
        for i = 1:Ngraph
            load("data\custom\graph\Aattribute_cosine_"+ string(i) + ".mat","Aattribute_cosine","-mat")
            save("data\graph\Aattribute_cosine_"+ string(i) + ".mat","Aattribute_cosine","-mat")
        end
    elseif opt2 == 1 
        load("data\feature\feature.mat","Ngraph", ...
            "fslope", "flandcover", "flithology");
        for i = 1:Ngraph
            sb = repmat(flithology(:,i),[1 2*500]);
            sc = repmat(flandcover(:,i),[1 2*500]);
            sd = repmat(fslope(:,i),[1 2*500]);
            Aattribute_cosine = ( (sb.*sb') + (sc.*sc') + (sd.*sd') ) ./ ...
                        ( sqrt(sb.^2+sc.^2+sd.^2) .* sqrt(sb'.^2+sc'.^2+sd'.^2) ) ;
            save("data\graph\Aattribute_cosine_"+ string(i) + ".mat","Aattribute_cosine","-mat")
        end 
    end

end