function [] = createADJsimplex()

    % load rasterized geospatial files - roads and settlements
    [s, R] = readgeoraster("data\settlement\settlement2022.tif");
    [r, ~] = readgeoraster("data\road\road.tif");
    s = sparse(s>0);
    r = sparse(r>0);
    listing = dir('data\mask\raster_maps');
    filelist = string({listing.name})';
        
    for i = 1:(numel(listing)-2)

        % load raster map mask file
        [m, ~] = readgeoraster("data\mask\raster_maps\"+filelist(2+i));
        m = sparse(m>0);
  
        % make the map binary
        rsm_adjidx = find( ((r(:)>0 | s(:)>0) & m(:)>0) == 1 );
        [rsm_adjrow, rsm_adjcol] = ind2sub(size(r),rsm_adjidx);
        rsm_adjrowcol = rsm_adjrow.*100000+rsm_adjcol;
        rsm_adjarray = logical(sparse(numel(rsm_adjidx),numel(rsm_adjidx)));

        % assign the value of 1 if the point is adjacent to each other
        parfor i = 1:numel(rsm_adjidx)
            temp = [    (rsm_adjrow(i)-1).*100000+(rsm_adjcol(i)-1); ...
                        (rsm_adjrow(i)-0).*100000+(rsm_adjcol(i)-1); ...
                        (rsm_adjrow(i)+1).*100000+(rsm_adjcol(i)-1); ...
                        (rsm_adjrow(i)-1).*100000+(rsm_adjcol(i)-0); ...
                        (rsm_adjrow(i)+1).*100000+(rsm_adjcol(i)-0); ...
                        (rsm_adjrow(i)-1).*100000+(rsm_adjcol(i)+1); ...
                        (rsm_adjrow(i)-0).*100000+(rsm_adjcol(i)+1); ...
                        (rsm_adjrow(i)+1).*100000+(rsm_adjcol(i)+1)     ];
            rsm_adjarray(i,:) = sparse(ismember(rsm_adjrowcol,temp)');
        end

        % save
        name = convertStringsToChars(filelist(2+i));
        save("data\mask\adjacency_files\"+convertCharsToStrings(name(1:end-15)),"rsm_adjidx","rsm_adjrow","rsm_adjcol","rsm_adjarray")

    end
end