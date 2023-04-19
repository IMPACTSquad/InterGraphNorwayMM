%% applyGCN.m is a script that perform graph convolutional network
clear
clc
close

%% 1. Load Data

% 1.1. load grapical structure and sample information

% load subset indexing
% subset.fid, subset.nodeidx
% subset.x, subset.y
% subset.YYYY, subset.MM, subset.DD, subset.H
load(['C:\Desktop\AI4ER\03 - MRes\Easter 2023\MRes Project\ArcticCCAM\data\' ...
    'subset_sample_5percent.mat'])

% load adjacency matrix
graphDatapath = "C:\Desktop\AI4ER\03 - MRes\Easter 2023\MRes Project\OneDrive - University of Cambridge\graphData\";
nodeidx_max = 0;
nodeidx_min = 1000;
unique_fid = unique(subset.fid);
for i = 1:numel(unique_fid)
    idx_date = find(subset.fid==unique_fid(i));
    idx_date = idx_date(1,1);
    load(graphDatapath+"fid"+num2str(unique_fid(i))+"_lsdate"+...
        subset.YYYY(idx_date)+subset.MM(idx_date)+subset.DD(idx_date)+".osm.mat")
    adjacencyMatrix_m = full(adjacencyMatrix(intersection_node_indices,intersection_node_indices));
    if nodeidx_min > size(adjacencyMatrix_m,1)
        nodeidx_min = size(adjacencyMatrix_m,1);
    end
    if nodeidx_max < size(adjacencyMatrix_m,1)
        nodeidx_max = size(adjacencyMatrix_m,1);
    end
end
adjacencyData = zeros(nodeidx_max,nodeidx_max,numel(unique(subset.fid)));
for i = 1:numel(unique_fid)
    idx_date = find(subset.fid==unique_fid(i));
    idx_date = idx_date(1,1);
    load(graphDatapath+"fid"+num2str(unique_fid(i))+"_lsdate"+...
        subset.YYYY(idx_date)+subset.MM(idx_date)+subset.DD(idx_date)+".osm.mat")
    adjacencyMatrix_m = full(adjacencyMatrix(intersection_node_indices,intersection_node_indices));
    adjacencyData(1:size(adjacencyMatrix_m,1),1:size(adjacencyMatrix_m,1),i) = ...
        full(adjacencyMatrix(intersection_node_indices,intersection_node_indices));
end

% 1.2. load independent variables
% load wind, air pressure, rainfall, and temperature
load(['C:\Desktop\AI4ER\03 - MRes\Easter 2023\MRes Project\ArcticCCAM\data\' ...
    'meteorological_data\data_features_MetNordic_20percent.mat'])
load(['C:\Desktop\AI4ER\03 - MRes\Easter 2023\MRes Project\ArcticCCAM\data\' ...
    'meteorological_data\data_features_seNorge_20percent.mat'])
windData = zeros(nodeidx_max,nodeidx_max,numel(unique(subset.fid)));
pressureData = zeros(nodeidx_max,nodeidx_max,numel(unique(subset.fid)));
temp1Data = zeros(nodeidx_max,nodeidx_max,numel(unique(subset.fid)));
rain1Data = zeros(nodeidx_max,nodeidx_max,numel(unique(subset.fid)));
for i = 1:numel(unique_fid)
    idx_date = find(subset.fid==unique_fid(i));
    idx_date = idx_date(1,1);
    load(graphDatapath+"fid"+num2str(unique_fid(i))+"_lsdate"+...
        subset.YYYY(idx_date)+subset.MM(idx_date)+subset.DD(idx_date)+".osm.mat")
    for j = 1:numel(intersection_node_indices)
        idx_temp = find(subset.nodeidx==intersection_node_indices(j)&subset.fid==unique_fid(i));
        windData(j,j,i) = wind_speed_10m(idx_temp(1,1),1);
        pressureData(j,j,i) = air_pressure_at_sea_level(idx_temp(1,1),1);
        temp1Data(j,j,i) = tg(idx_temp(1,1),1);
        rain1Data(j,j,i) = rr(idx_temp(1,1),1);
    end
end

% 1.3. load dependent variables
% load label - binary and continuous
load(['C:\Desktop\AI4ER\03 - MRes\Easter 2023\MRes Project\ArcticCCAM\data\' ...
    'road_network\summaryLABEL.mat'])
binaryLABEL = zeros(numel(unique(subset.fid)),nodeidx_max);
rangeLABEL = zeros(numel(unique(subset.fid)),nodeidx_max);
lenLABEL = zeros(numel(unique(subset.fid)),1);
for i = 1:numel(unique_fid)
    idx_date = find(subset.fid==unique_fid(i));
    idx_date = idx_date(1,1);
    load(graphDatapath+"fid"+num2str(unique_fid(i))+"_lsdate"+...
        subset.YYYY(idx_date)+subset.MM(idx_date)+subset.DD(idx_date)+".osm.mat")
    lenLABEL(i,1) = numel(intersection_node_indices);
    for j = 1:numel(intersection_node_indices)
        idx_temp = find(summaryCOORDS(:,2)==intersection_node_indices(j)&summaryCOORDS(:,1)==unique_fid(i));
        binaryLABEL(i,j) = binarylabel(idx_temp(1,1),1);
        rangeLABEL(i,j) = contlabel(idx_temp(1,1),1);
    end
end
clear adjacencyMatrix_m adjacencyMatrix air_pressure_at_sea_level binarylabel centroid connectivity_matrix
clear contlabel date distance feature graphDatapath i idx_temp idx_date intersection_nodes intersection_node_indices
clear j lstype nnodes nodeidx_min nodeidx_max rr rr_npast subset summaryCOORDS tg tg_npast wind_speed_10m

%% Preprocess Graph Data
numObservations = size(adjacencyData,3);
[idxTrain,idxValidation,idxTest] = trainingPartitions(numObservations,[0.8 0.1 0.1]);


%adjacency matrix
adjacencyTrain = adjacencyData(:,:,idxTrain);
adjacencyValidation = adjacencyData(:,:,idxValidation);
adjacencyTest = adjacencyData(:,:,idxTest);

%features
windTrain = windData(:,:,idxTrain);
windValidation = windData(:,:,idxValidation);
windTest = windData(:,:,idxTest);
[~,XTrain_wind] = preprocessPredictors(adjacencyTrain,windTrain);
[~,XValidation_wind] = preprocessPredictors(adjacencyValidation,windValidation);
[~,XTest_wind] = preprocessPredictors(adjacencyTest,windTest);

pressureTrain = pressureData(:,:,idxTrain);
pressureValidation = pressureData(:,:,idxValidation);
pressureTest = pressureData(:,:,idxTest);
[~,XTrain_pressure] = preprocessPredictors(adjacencyTrain,pressureTrain);
[~,XValidation_pressure] = preprocessPredictors(adjacencyValidation,pressureValidation);
[~,XTest_pressure] = preprocessPredictors(adjacencyTest,pressureTest);

temp1Train = temp1Data(:,:,idxTrain);
temp1Validation = temp1Data(:,:,idxValidation);
temp1Test = temp1Data(:,:,idxTest);
[~,XTrain_temp1] = preprocessPredictors(adjacencyTrain,temp1Train);
[~,XValidation_temp1] = preprocessPredictors(adjacencyValidation,temp1Validation);
[~,XTest_temp1] = preprocessPredictors(adjacencyTest,temp1Test);

rain1Train = rain1Data(:,:,idxTrain);
rain1Validation = rain1Data(:,:,idxValidation);
rain1Test = rain1Data(:,:,idxTest);
[~,XTrain_rain1] = preprocessPredictors(adjacencyTrain,rain1Train);
[~,XValidation_rain1] = preprocessPredictors(adjacencyValidation,rain1Validation);
[~,XTest_rain1] = preprocessPredictors(adjacencyTest,rain1Test);

featureTrain = cat(2,XTrain_wind,XTrain_pressure,XTrain_temp1,XTrain_rain1);
featureValidation = cat(2,XValidation_wind,XValidation_pressure,XValidation_temp1,XValidation_rain1);
featureTest = cat(2,XTest_wind,XTest_pressure,XTest_temp1,XTest_rain1);

%labels
bLABELTrain = binaryLABEL(idxTrain,:);
bLABELValidation = binaryLABEL(idxValidation,:);
bLABELTest = binaryLABEL(idxTest,:);

rLABELTrain = rangeLABEL(idxTrain,:);
rLABELValidation = rangeLABEL(idxValidation,:);
rLABELTest = rangeLABEL(idxTest,:);

lenLABELTrain = lenLABEL(idxTrain,1);
lenLABELValidation = lenLABEL(idxValidation,1);
lenLABELTest = lenLABEL(idxTest,1);

%reformat following GCN requirement
[ATrain,~,labelsTrain] = preprocessData(adjacencyTrain,rain1Train,rLABELTrain,lenLABELTrain);
[AValidation,~,labelsValidation] = preprocessData(adjacencyValidation,rain1Validation,rLABELValidation,lenLABELValidation);

muX = mean(featureTrain);
sigsqX = var(featureTrain,1);

XTrain = (featureTrain - muX)./sqrt(sigsqX);
XValidation = (featureValidation - muX)./sqrt(sigsqX);

%% Define Deep Learning Model

parameters = struct;

numHiddenFeatureMaps = 32;
numInputFeatures = size(XTrain,2);

sz = [numInputFeatures numHiddenFeatureMaps];
numOut = numHiddenFeatureMaps;
numIn = numInputFeatures;
parameters.mult1.Weights = initializeGlorot(sz,numOut,numIn,"double");

sz = [numHiddenFeatureMaps numHiddenFeatureMaps];
numOut = numHiddenFeatureMaps;
numIn = numHiddenFeatureMaps;
parameters.mult2.Weights = initializeGlorot(sz,numOut,numIn,"double");

classes = categories(labelsTrain);
numClasses = numel(classes);

sz = [numHiddenFeatureMaps numClasses];
numOut = numClasses;
numIn = numHiddenFeatureMaps;
parameters.mult3.Weights = initializeGlorot(sz,numOut,numIn,"double");

%% Specify Training Options

numEpochs = 1500;
learnRate = 0.01;
validationFrequency = 300;

%% Train Model

trailingAvg = [];
trailingAvgSq = [];

XTrain = dlarray(XTrain);
XValidation = dlarray(XValidation);

TTrain = onehotencode(labelsTrain,2,ClassNames=classes);
TValidation = onehotencode(labelsValidation,2,ClassNames=classes);

monitor = trainingProgressMonitor( ...
    Metrics=["TrainingLoss","ValidationLoss"], ...
    Info="Epoch", ...
    XLabel="Epoch");

groupSubPlot(monitor,"Loss",["TrainingLoss","ValidationLoss"])

epoch = 0;

while epoch < numEpochs && ~monitor.Stop
    epoch = epoch + 1;

    % Evaluate the model loss and gradients.
    [loss,gradients] = dlfeval(@modelLoss,parameters,XTrain,ATrain,TTrain);

    % Update the network parameters using the Adam optimizer.
    [parameters,trailingAvg,trailingAvgSq] = adamupdate(parameters,gradients, ...
        trailingAvg,trailingAvgSq,epoch,learnRate);

    % Record the training loss and epoch.
    recordMetrics(monitor,epoch,TrainingLoss=loss);
    updateInfo(monitor,Epoch=(epoch+" of "+numEpochs));

    % Display the validation metrics.
    if epoch == 1 || mod(epoch,validationFrequency) == 0
        YValidation = model(parameters,XValidation,AValidation);
        lossValidation = crossentropy(YValidation,TValidation,DataFormat="BC");

        % Record the validation loss.
        recordMetrics(monitor,epoch,ValidationLoss=lossValidation);
    end

    monitor.Progress = 100*(epoch/numEpochs);
end

%% Test Model

[ATest,~,labelsTest] = preprocessData(adjacencyTest,rain1Test,rLABELTest,lenLABELTest);
XTest = (featureTest - muX)./sqrt(sigsqX);

XTest = dlarray(XTest);

YTest = model(parameters,XTest,ATest);
YTest = onehotdecode(YTest,classes,2);

accuracy = mean(YTest == labelsTest)


figure
cm = confusionchart(labelsTest,YTest, ...
    ColumnSummary="column-normalized", ...
    RowSummary="row-normalized");
title("Confusion Chart");