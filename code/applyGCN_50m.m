%% applyGCN.m is a script that perform graph convolutional network
clear
clc
close

%% load the location of landslide incidents
ls = readtable(['C:\Desktop\AI4ER\03 - MRes\Easter 2023\' ...
    'MRes Project\ArcticCCAM\data\landslide_incidents\' ...
    'landslide_incidents_1747_near_railway_addXY.xlsx']);

%% Preprocess Graph Data
load(['C:\Desktop\AI4ER\03 - MRes\Easter 2023\MRes Project\' ...
    'ArcticCCAM\data\landslide_incidents\' ...
    'validindices_equallyrepresented.mat'])
steepnesspath = ['C:\Desktop\AI4ER\03 - MRes\Easter 2023\MRes Project\' ...
    'ArcticCCAM\data\steepness_landslide\equallyrepresented'];
metpath = ['C:\Desktop\AI4ER\03 - MRes\Easter 2023\MRes Project\' ...
    'ArcticCCAM\data\meteorological_data\equallyrepresented'];
%partition
rng(1); %seed number

% check seNorge
fid_f2 = [];
for i = 1:numel(fid_f)
    load(metpath+"\"+string(fid_f(i))+"metseNorgeSnow.mat")
    if ~anynan(seNorgeSnow_swepr)
        fid_f2 = [fid_f2; fid_f(i)];
    end
end 

numObservations = numel(fid_f2);
[idxTrain,idxValidation,idxTest] = trainingPartitions(numObservations,[0.8 0.1 0.1]);

% feature
featureTrain = sparse([]);
featureValidation = sparse([]);
featureTest = sparse([]);
for i = 1:numel(idxTrain)
    load(steepnesspath+"\"+string(fid_f2(idxTrain(i)))+"steepness.mat")
    load(metpath+"\"+string(fid_f2(idxTrain(i)))+"metseNorge.mat")
    load(metpath+"\"+string(fid_f2(idxTrain(i)))+"metseNorgeSnow.mat")
    featureTrain = [featureTrain; 
        % cat(2,  steepness, ...
        %         seNorge_rr)];
        cat(2,  steepness, ...
                seNorge_rr, seNorge_tg, ... 
                seNorgeSnow_swepr, seNorgeSnow_swe, seNorgeSnow_ski, ...
                seNorgeSnow_sdfsw, seNorgeSnow_sd, seNorgeSnow_qtt, ...
                seNorgeSnow_qsw, seNorgeSnow_lwc, seNorgeSnow_fsw)];
    % featureTrain = [featureTrain; 
    %     cat(2,  steepness, ...
    %             seNorge_rr, seNorge_tg)]; 
end 
for i = 1:numel(idxValidation)
    load(steepnesspath+"\"+string(fid_f2(idxValidation(i)))+"steepness.mat")
    load(metpath+"\"+string(fid_f2(idxValidation(i)))+"metseNorge.mat")
    load(metpath+"\"+string(fid_f2(idxValidation(i)))+"metseNorgeSnow.mat")
    featureValidation = [featureValidation; 
        cat(2,  steepness, ...
                seNorge_rr, seNorge_tg, ... 
                seNorgeSnow_swepr, seNorgeSnow_swe, seNorgeSnow_ski, ...
                seNorgeSnow_sdfsw, seNorgeSnow_sd, seNorgeSnow_qtt, ...
                seNorgeSnow_qsw, seNorgeSnow_lwc, seNorgeSnow_fsw)];
end 
for i = 1:numel(idxTest)
    load(steepnesspath+"\"+string(fid_f2(idxTest(i)))+"steepness.mat")
    load(metpath+"\"+string(fid_f2(idxTest(i)))+"metseNorge.mat")
    load(metpath+"\"+string(fid_f2(idxTest(i)))+"metseNorgeSnow.mat")
    featureTest = [featureTest; 
        cat(2,  steepness, ...
                seNorge_rr, seNorge_tg, ... 
                seNorgeSnow_swepr, seNorgeSnow_swe, seNorgeSnow_ski, ...
                seNorgeSnow_sdfsw, seNorgeSnow_sd, seNorgeSnow_qtt, ...
                seNorgeSnow_qsw, seNorgeSnow_lwc, seNorgeSnow_fsw)];
end 

muX = mean(featureTrain);
sigsqX = var(featureTrain,1);
XTrain = (featureTrain - muX)./sqrt(sigsqX);
XValidation = (featureValidation - muX)./sqrt(sigsqX);
XTest = (featureTest - muX)./sqrt(sigsqX);

% adjacency matrix
adjpath = ['C:\Desktop\AI4ER\03 - MRes\Easter 2023\MRes Project\' ...
    'ArcticCCAM\data\road_network\graphData_railway_equallyrepresented'];
ATrain = sparse([]);
AValidation = sparse([]);
ATest = sparse([]);
for i = 1:numel(idxTrain)
    load(adjpath+"\"+string(fid_f2(idxTrain(i)))+".mat")
    ATrain = blkdiag(ATrain,adj);
end 
for i = 1:numel(idxValidation)
    load(adjpath+"\"+string(fid_f2(idxValidation(i)))+".mat")
    AValidation = blkdiag(AValidation,adj);
end 
for i = 1:numel(idxTest)
    load(adjpath+"\"+string(fid_f2(idxTest(i)))+".mat")
    ATest = blkdiag(ATest,adj);
end 

% labels
% choose two_label, three_label, four_label, five_label, six_label
labelpath = ['C:\Desktop\AI4ER\03 - MRes\Easter 2023\MRes Project\' ...
    'ArcticCCAM\data\landslide_incidents\equallyrepresented'];
labelsTrain = categorical([]);
labelsValidation = categorical([]);
labelsTest = categorical([]);
for i = 1:numel(idxTrain)
    load(labelpath+"\"+string(fid_f2(idxTrain(i)))+"label.mat")
    labelsTrain = [labelsTrain; categorical(two_label)];
end 
for i = 1:numel(idxValidation)
    load(labelpath+"\"+string(fid_f2(idxValidation(i)))+"label.mat")
    labelsValidation = [labelsValidation; categorical(two_label)];
end 
for i = 1:numel(idxTest)
    load(labelpath+"\"+string(fid_f2(idxTest(i)))+"label.mat")
    labelsTest = [labelsTest; categorical(two_label)];
end 

%% Define Deep Learning Model

parameters = struct;

numHiddenFeatureMaps = 512;
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

numEpochs = 10000;
learnRate = 0.01;
validationFrequency = 10;

%% Train Model

trailingAvg = [];
trailingAvgSq = [];

XTrain = dlarray(full(XTrain));
XValidation = dlarray(full(XValidation));
XTest = dlarray(full(XTest));

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
YTrain = model(parameters,XTrain,ATrain);
YTrain = onehotdecode(YTrain,classes,2);
accuracy = mean(YTrain == labelsTrain)

YValidation = model(parameters,XValidation,AValidation);
YValidation = onehotdecode(YValidation,classes,2);
accuracy = mean(YValidation == labelsValidation)

YTest = model(parameters,XTest,ATest);
YTest = onehotdecode(YTest,classes,2);
accuracy = mean(YTest == labelsTest)

figure
cm = confusionchart(labelsTrain,YTrain, ...
    ColumnSummary="column-normalized", ...
    RowSummary="row-normalized");
title("Confusion Chart");

figure
cm = confusionchart(labelsValidation,YValidation, ...
    ColumnSummary="column-normalized", ...
    RowSummary="row-normalized");
title("Confusion Chart");

figure
cm = confusionchart(labelsTest,YTest, ...
    ColumnSummary="column-normalized", ...
    RowSummary="row-normalized");
title("Confusion Chart");

%% Export Results
% for i = 1:numel(ls85.fid)
% 
% end