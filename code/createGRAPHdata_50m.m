%% load data
[n, nR] = readgeoraster(['C:\Desktop\AI4ER\03 - MRes\Easter 2023\' ...
    'MRes Project\resolution_study\railyway_rasterized_50m.tif']);
n = sparse(1.*(n>0)); %binary: 0 - no railway/road, 1 - with railway/road

%% load the location of landslide incidents
ls = readtable(['C:\Desktop\AI4ER\03 - MRes\Easter 2023\' ...
    'MRes Project\ArcticCCAM\data\landslide_incidents\' ...
    'landslide_incidents_1747_near_railway_addXY.xlsx']);

% compute layer extent for each landslide incident
width = 5000; %5km box
res = 50; %50m resolution
x_min = nR.XWorldLimits(1);
x_max = nR.XWorldLimits(2);
y_min = nR.YWorldLimits(1);
y_max = nR.YWorldLimits(2);

x_fromleft = round((ls.x - x_min)./res,0);
y_fromtop = round((y_max - ls.y)./res,0);

% layer i's bounds
il = x_fromleft - (width / res / 2);
ir = x_fromleft + ((width / res / 2) - 1);
ir = (il < 1) .* (width / res) + ...
     (ir > (x_max-x_min)/res) .* (x_max-x_min)/res + ...
     ir;
il = (il < 1) .* 1 + ...
     (ir > (x_max-x_min)/res) .* ((x_max-x_min)/res-(width/res)+1) + ...
     il;
it = y_fromtop - (width / res / 2);
ib = y_fromtop + ((width / res / 2) - 1);
ib = (it < 1) .* (width / res) + ...
     (ib > (y_max-y_min)/res) .* (y_max-y_min)/res + ...
     ib;
it = (it < 1) .* 1 + ...
     (ib > (y_max-y_min)/res) .* ((y_max-y_min)/res-(width/res)+1) + ...
     it;

%% create adjacency metrix for each lanslide incident and combine them into one single matrix
tic
outputpath = ['C:\Desktop\AI4ER\03 - MRes\Easter 2023\MRes Project\' ...
    'ArcticCCAM\data\road_network\graphData_railway_5km_50m'];
for k = 1:numel(ls.fid)
    disp(k/numel(ls.fid)*100)
    n_sub = n(it(k):ib(k),il(k):ir(k));
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
    m = matfile(outputpath+"\"+string(ls.fid(k))+".mat",'writable',true);
    m.adj = adj;
    m.row = row;
    m.col = col;
    m.n_sub = n_sub;
    toc
end
toc

% takes 300 seconds for the railway dataset