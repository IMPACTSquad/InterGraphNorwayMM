function [record,parameter_history] = runGCN(   numEpochs,learnRate,...
                                                XTrain,XValidation,XTest,...
                                                ATrainNorm,AValidationNorm,ATestNorm,...
                                                labelsTrain,labelsValidation,labelsTest,...
                                                seed_random,h)

    [parameters] = initializeDL(size(XTrain,2),labelsTrain,seed_random);

    trailingAvg = [];
    trailingAvgSq = [];

    classes = categories(labelsTrain);
    XTrain = dlarray(full(XTrain));
    TTrain = onehotencode(labelsTrain,2,ClassNames=classes);
    XValidation = dlarray(full(XValidation));
    TValidation = onehotencode(labelsValidation,2,ClassNames=classes);
    XTest = dlarray(full(XTest));
    TTest = onehotencode(labelsTest,2,ClassNames=classes);
    
    epoch = 0;
    record = [];
    parameter_history = [];

    while epoch < numEpochs

        epoch = epoch + 1;
        
        % Evaluate the model loss and gradients.
        [loss,gradients] = dlfeval(@modelLoss,parameters,XTrain,ATrainNorm,TTrain);
        parameter_history = [parameter_history; parameters];
        [YTrain,~,~,~] = model(parameters,XTrain,ATrainNorm);
        thresh = ((0:100)/1000)';
        ith_percentile = (0:0.01:1)';
        TP = zeros(numel(thresh),1);
        TN = zeros(numel(thresh),1);
        FN = zeros(numel(thresh),1);
        FP = zeros(numel(thresh),1);
        labels = double(labelsTrain);
        YTrain = extractdata(YTrain(:,2));
        for t = 1:numel(ith_percentile)
            thresh = quantile(YTrain,ith_percentile(t));
            TP(t,1) = sum(( (labels == 2) & (YTrain > thresh) ));
            TN(t,1) = sum(( (labels == 1) & (YTrain <= thresh) ));
            FN(t,1) = sum(( (labels == 2) & (YTrain <= thresh) ));
            FP(t,1) = sum(( (labels == 1) & (YTrain > thresh) ));
        end
        TPR = TP ./ (TP + FN);
        FPR = FP ./ (FP + TN);
        trainAUC = -trapz(FPR,TPR);
        
        % Record validation AUC
        [lossValidation,~] = dlfeval(@modelLoss,parameters,XTest,AValidationNorm,TValidation);
        [YValidation,~,~,~] = model(parameters,XValidation,AValidationNorm);
        thresh = ((0:100)/1000)';
        ith_percentile = (0:0.01:1)';
        TP = zeros(numel(thresh),1);
        TN = zeros(numel(thresh),1);
        FN = zeros(numel(thresh),1);
        FP = zeros(numel(thresh),1);
        labels = double(labelsValidation);
        YValidation = extractdata(YValidation(:,2));
        for t = 1:numel(ith_percentile)
            thresh = quantile(YValidation,ith_percentile(t));
            TP(t,1) = sum(( (labels == 2) & (YValidation > thresh) ));
            TN(t,1) = sum(( (labels == 1) & (YValidation <= thresh) ));
            FN(t,1) = sum(( (labels == 2) & (YValidation <= thresh) ));
            FP(t,1) = sum(( (labels == 1) & (YValidation > thresh) ));
        end
        TPR = TP ./ (TP + FN);
        FPR = FP ./ (FP + TN);
        validAUC = -trapz(FPR,TPR);
        
        [YTest,~,~,~] = model(parameters,XTest,ATestNorm);
        thresh = ((0:100)/1000)';
        ith_percentile = (0:0.01:1)';
        TP = zeros(numel(thresh),1);
        TN = zeros(numel(thresh),1);
        FN = zeros(numel(thresh),1);
        FP = zeros(numel(thresh),1);
        labels = double(labelsTest);
        YTest = extractdata(YTest(:,2));
        for t = 1:numel(ith_percentile)
            thresh = quantile(YTest,ith_percentile(t));
            TP(t,1) = sum(( (labels == 2) & (YTest > thresh) ));
            TN(t,1) = sum(( (labels == 1) & (YTest <= thresh) ));
            FN(t,1) = sum(( (labels == 2) & (YTest <= thresh) ));
            FP(t,1) = sum(( (labels == 1) & (YTest > thresh) ));
        end
        TPR = TP ./ (TP + FN);
        FPR = FP ./ (FP + TN);
        testAUC = -trapz(FPR,TPR);
        
        record = [record; [epoch loss lossValidation trainAUC validAUC testAUC]];
        
        % Update the network parameters using the Adam optimizer.
        [parameters,trailingAvg,trailingAvgSq] = adamupdate(parameters,gradients, ...
            trailingAvg,trailingAvgSq,epoch,learnRate);
    
    end

end

