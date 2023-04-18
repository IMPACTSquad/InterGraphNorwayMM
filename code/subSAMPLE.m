clear, clc, close

numNODES = readtable("C:\Desktop\AI4ER\03 - MRes\Easter 2023\MRes Project\ArcticCCAM\data\road_network\numNODES.xlsx");
filename = string(numNODES.filename);
nnodes = numNODES.nnodes;

sampleN = readtable("C:\Desktop\AI4ER\03 - MRes\Easter 2023\MRes Project\ArcticCCAM\data\subset_sample_5percent.xlsx");
sampleN_nnodes = sampleN.nnodes;
sampleN_nfid2 = sampleN.nfid2;
temp = [];

for i = 1:numel(sampleN_nnodes)
    idx = datasample(find(nnodes==sampleN_nnodes(i)),sampleN_nfid2(i));
    temp = [temp; ...
        filename(idx) nnodes(idx)];
end 

samples = zeros(size(temp,1),2);
for i = 1:size(temp,1)
    tmp = convertStringsToChars(temp(i,1));
    samples(i,1) = str2num(tmp(4:end-19));
    samples(i,2) = str2num(temp(i,2));
end

load('C:\Desktop\AI4ER\03 - MRes\Easter 2023\MRes Project\ArcticCCAM\data\road_network\summaryLABEL.mat')
feature = struct();
feature.fid = summaryCOORDS(:,1);
feature.nodeidx = summaryCOORDS(:,2);
feature.x = summaryCOORDS(:,3);
feature.y = summaryCOORDS(:,4);
feature.lstype = lstype;
feature.YYYY = date(:,1);
feature.MM = date(:,2);
feature.DD = date(:,3);
feature.H = date(:,4);
feature.M = date(:,5);
feature.S = date(:,6);
feature.YYYY = string(arrayfun(@(x) sprintf('%04d', x), feature.YYYY, 'Uniform', 0));
feature.MM = string(arrayfun(@(x) sprintf('%02d', x), feature.MM, 'Uniform', 0));
feature.DD = string(arrayfun(@(x) sprintf('%02d', x), feature.DD, 'Uniform', 0));
feature.H = string(arrayfun(@(x) sprintf('%02d', x), feature.H, 'Uniform', 0));
feature.M = string(arrayfun(@(x) sprintf('%02d', x), feature.M, 'Uniform', 0));
feature.S = string(arrayfun(@(x) sprintf('%02d', x), feature.S, 'Uniform', 0));

subset = struct();
subset.fid = [];
subset.nodeidx = [];
subset.x = [];
subset.y = [];
subset.YYYY = [];
subset.MM = [];
subset.DD = [];
subset.H = [];
for i = 1:size(samples,1)
    subset.fid = [subset.fid; feature.fid(feature.fid==samples(i,1))];
    subset.nodeidx = [subset.nodeidx; feature.nodeidx(feature.fid==samples(i,1))];
    subset.x = [subset.x; feature.x(feature.fid==samples(i,1))];
    subset.y = [subset.y; feature.y(feature.fid==samples(i,1))];
    subset.YYYY = [subset.YYYY; feature.YYYY(feature.fid==samples(i,1))];
    subset.MM = [subset.MM; feature.MM(feature.fid==samples(i,1))];
    subset.DD = [subset.DD; feature.DD(feature.fid==samples(i,1))];
    subset.H = [subset.H; feature.H(feature.fid==samples(i,1))];
end
