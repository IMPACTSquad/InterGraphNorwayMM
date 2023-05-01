%% load data
tic
[n, nR] = readgeoraster(['C:\Desktop\AI4ER\03 - MRes\Easter 2023\' ...
    'MRes Project\resolution_study\railyway_rasterized_50m.tif']);
n = sparse(1.*(n>0)); %binary: 0 - no railway/road, 1 - with railway/road
x_min = nR.XWorldLimits(1);
x_max = nR.XWorldLimits(2);
y_min = nR.YWorldLimits(1);
y_max = nR.YWorldLimits(2);
toc
disp('Rasterized Network System Loaded')


%% load the location of landslide incidents
ls = readtable(['C:\Desktop\AI4ER\03 - MRes\Easter 2023\' ...
    'MRes Project\ArcticCCAM\data\landslide_incidents\' ...
    'landslide_incidents_1747_near_railway_addXY.xlsx']);
x_fromleft = round((ls.x - x_min)./res,0);
y_fromtop = round((y_max - ls.y)./res,0);
toc
disp('Landslide Incident Information Loaded')

%% get the representative size of each landslide incident
tic
res = 50; %50m resolution (based on the quality of steepness map)
dh = repmat((3:2:2*100)',[100 1]).*res;  %search space
dw = repelem((3:2:2*100)',100).*res;     %search space
n_sub_area = (dh.*dw);
fid_f = [];
dh_f = [];          %final selected height
dw_f = [];           %final selected height
for i = 1:numel(ls.fid)
    disp(i*100/numel(ls.fid))
    il = x_fromleft(i) - (dw / res / 2);
    ir = x_fromleft(i) + ((dw / res / 2) - 1);
    ir = (il < 1) .* (dw / res) + ...
         (ir > (x_max-x_min)/res) .* (x_max-x_min)/res + ...
         ir;
    il = (il < 1) .* 1 + ...
         (ir > (x_max-x_min)/res) .* ((x_max-x_min)/res-(dw/res)+1) + ...
         il;
    it = y_fromtop(i) - (dh / res / 2);
    ib = y_fromtop(i) + ((dh / res / 2) - 1);
    ib = (it < 1) .* (dh / res) + ...
         (ib > (y_max-y_min)/res) .* (y_max-y_min)/res + ...
         ib;
    it = (it < 1) .* 1 + ...
         (ib > (y_max-y_min)/res) .* ((y_max-y_min)/res-(dh/res)+1) + ...
         it;
    n_sub_counts = zeros(numel(it),2);
    for k = 1:numel(it)
        n_sub = full(n(int64(it(k)):int64(ib(k)),int64(il(k)):int64(ir(k))));
        idx = find(n_sub == 1);
        if isempty(idx)
            n_sub_counts(k,1) = 0;
            n_sub_counts(k,2) = 0;
        else
            row = zeros(numel(idx),1);
            col = zeros(numel(idx),1);
            for m = 1:numel(idx) 
                [row(m,1), col(m,1)] =  ind2sub(size(n_sub),idx(m));
            end
            col_x = x_min + (il(k)+col-0.5).*(res);
            row_y = y_max - (it(k)+row-1.0).*(res);
            distance = sqrt((col_x-repmat(ls.x(i),[numel(col_x) 1])).^2+...
                        (row_y-repmat(ls.y(i),[numel(row_y) 1])).^2);
            n_sub_counts(k,1) = sum(distance<85);               %number of affected network pixel
            n_sub_counts(k,2) = sum(distance>=85&distance<385); %number of unaffected network pixel
        end
    end
    n_sub_ratio = n_sub_counts(:,1)./n_sub_counts(:,2);
    chosen_sizes_idx = find(n_sub_ratio==1);
    if isempty(chosen_sizes_idx)
        chosen_sizes_idx = find(n_sub_ratio>0.95&n_sub_ratio<1.05);
    end
    if ~isempty(chosen_sizes_idx)
        dhdw_idx = find(n_sub_area==min(n_sub_area(chosen_sizes_idx)));
        fid_f = [fid_f; ls.fid(i)];
        dh_f = [dh_f; dh(dhdw_idx(1))];
        dw_f = [dw_f; dw(dhdw_idx(1))];
    end
    toc
end
toc
disp('Rectangular Extents Calculated')
outputpath = ['C:\Desktop\AI4ER\03 - MRes\Easter 2023\MRes Project\' ...
    'ArcticCCAM\data\landslide_incidents'];
m = matfile(outputpath+"\"+"validindices_equallyrepresented.mat",'writable',true);
m.fid_f = fid_f;
m.dh_f = dh_f;
m.dw_f = dw_f;

%% create adjacency metrix for each lanslide incident and combine them into one single matrix
tic
adjpath = ['C:\Desktop\AI4ER\03 - MRes\Easter 2023\MRes Project\' ...
    'ArcticCCAM\data\road_network\graphData_railway_equallyrepresented'];
for k = 1:numel(fid_f)
    disp(k/numel(fid_f)*100)
    i = find(ls.fid==fid_f(k));
    il = x_fromleft(i) - (dw_f(k) / res / 2);
    ir = x_fromleft(i) + ((dw_f(k) / res / 2) - 1);
    ir = (il < 1) .* (dw_f(k) / res) + ...
         (ir > (x_max-x_min)/res) .* (x_max-x_min)/res + ...
         ir;
    il = (il < 1) .* 1 + ...
         (ir > (x_max-x_min)/res) .* ((x_max-x_min)/res-(dw_f(k)/res)+1) + ...
         il;
    it = y_fromtop(i) - (dh_f(k) / res / 2);
    ib = y_fromtop(i) + ((dh_f(k) / res / 2) - 1);
    ib = (it < 1) .* (dh_f(k) / res) + ...
         (ib > (y_max-y_min)/res) .* (y_max-y_min)/res + ...
         ib;
    it = (it < 1) .* 1 + ...
         (ib > (y_max-y_min)/res) .* ((y_max-y_min)/res-(dh_f(k)/res)+1) + ...
         it;
    n_sub = n(int64(it):int64(ib),int64(il):int64(ir));
    idx = find(n_sub == 1);
    row = zeros(numel(idx),1);
    col = zeros(numel(idx),1);
    for i = 1:numel(idx) 
        [row(i,1), col(i,1)] =  ind2sub(size(n_sub),idx(i));
    end
    adj = zeros(numel(idx),numel(idx));
    for j = 1:numel(idx)
        adj(j,1:numel(idx)) = ...
            (abs(row(j)-row(1:numel(idx)))<=1 & abs(col(j)-col(1:numel(idx)))<=1)';
    end
    m = matfile(adjpath+"\"+string(fid_f(k))+".mat",'writable',true);
    m.adj = adj;
    m.row = row;
    m.col = col;
    m.it = it;
    m.ib = ib;
    m.il = il;
    m.ir = ir;
    m.n_sub = n_sub;
    toc
end
toc

% takes 300 seconds for the railway dataset