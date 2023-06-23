function [] = applyGNN(opt3)

    % Load feature information from running prepareData()
    f = load("data\feature\feature.mat");
    numEpochs = 50;
    learnRate = 0.001;

    if opt3 == 0

        for seed_random = 1:20

            % Load custom result file
            load("results\custom\multiHyperparameter_final_opt3c_"+string(seed_random)+".mat", ...
                "trainAUC_map","validAUC_map","testAUC_map",...
                "muX_map","sigsqX_map",...
                "epoch_map","parameter_map","-mat")

            % Save
            save("results\applyGNN\multiHyperparameter_final_opt3c_"+string(seed_random)+".mat", ...
                "trainAUC_map","validAUC_map","testAUC_map",...
                "muX_map","sigsqX_map",...
                "epoch_map","parameter_map","-mat")

        end

    elseif opt3 == 1

        % Hyperparameters - Feature Selection
        % The columns refer to the following listing:
        % fsuscep
        % fsteepness
        % frr
        % ftgC
        % fsd
        % fswe
        % ffsw
        % fslope
        % flithology
        % flandcover
        h.feature = [   1 1 1 1 1 1 0 1 0 0;...
                        1 1 1 1 1 0 1 1 0 0;...
                        1 1 1 1 1 0 0 1 1 0;...
                        1 1 1 1 1 0 0 1 0 1;...
                        1 1 1 1 0 1 1 1 0 0;...
                        1 1 1 1 0 1 0 1 1 0;...
                        1 1 1 1 0 1 0 1 0 1;...
                        1 1 1 1 0 0 1 1 1 0;...
                        1 1 1 1 0 0 1 1 0 1;...
                        1 1 1 1 0 0 0 1 1 1;...
                        1 1 0 1 0 1 0 1 1 1]; %Feature Selection
        
        % Initialize output Arrays
        trainAUC_map = zeros(f.Ngraph,size(h.feature,1));           
        validAUC_map = trainAUC_map;
        testAUC_map = trainAUC_map;
        epoch_map = trainAUC_map;
        parameter_map = cell(f.Ngraph,size(h.feature,1));     
        muX_map = parameter_map;
        sigsqX_map = parameter_map;

        % Execute multiple training of ML models given different random
        % seeds and for every graph machine learning models
        for seed_random = 1:20
            for iN = 1:f.Ngraph
                for iF = 1:size(h.feature,1)
    
                    % Split the dataset into training, validation, and testing
                    [idxSplit] = splitData(size(f.NgridIDxGraph,1)/2);

                    % Divide the feature vectors given split indices
                    [XTrain,XValidation,XTest,muX,sigsqX] = preprocessFeature(idxSplit,f,h,iN,iF);

                    % Load and normalize adjacency matrices
                    An = load("data\graph\Aspatial_12000.mat","Aspatial");
                    Aa = load("data\graph\Aattribute_cosine_"+string(iN)+".mat","Aattribute_cosine");
                    [ATrainNorm,AValidationNorm,ATestNorm] = preprocessAdjacency(An,Aa,idxSplit,iN);

                    % Preprocess labels given split indices
                    [labelsTrain,labelsValidation,labelsTest] = preprocessLabel(idxSplit);
                    
                    % Perform graph convolutional network
                    [record,parameter_history] = runGCN(numEpochs,learnRate,...
                                                        XTrain,XValidation,XTest,...
                                                        ATrainNorm,AValidationNorm,ATestNorm,...
                                                        labelsTrain,labelsValidation,labelsTest,...
                                                        seed_random,h);
    
                    % Obtain the best epoch (bestidx) with the lowest validation loss
                    bestidx = find(extractdata(record(:,3))==min(extractdata(record(5:end,3))));

                    % Save the corresponding the metrics given the best epoch
                    trainAUC_map(iN,iF) = record(bestidx,4);
                    validAUC_map(iN,iF) = record(bestidx,5);
                    testAUC_map(iN,iF) = record(bestidx,6);
                    epoch_map(iN,iF) = record(bestidx,1);
                    muX_map{iN,iF} = muX;
                    sigsqX_map{iN,iF} = sigsqX;
                    parameter_map{iN,iF} = parameter_history(bestidx,:);
    
                end
            end

            save("results\applyGNN\multiHyperparameter_final_opt3c_"+string(seed_random)+".mat", ...
                "trainAUC_map","validAUC_map","testAUC_map",...
                "muX_map","sigsqX_map",...
                "epoch_map","parameter_map","-mat")

        end

        

    end
end
