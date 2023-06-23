function [] = selectGNN(opt3)

    if opt3 == 0

        % Load custom result file
        load("results\custom\selectGNN_results.mat", ...
            'AUC','optimal_threshold','OPTROCPT','selection', ...
            "opt3","T","X","Y","label_allmap","YTest_allmap",...
            "optimal_testAUC_summary","optimal_validAUC_summary","optimal_trainAUC_summary",...
            "optimal_trainAUC","optimal_testAUC","optimal_validAUC","optimal_features")

        % Plot collective ROC curve
        figure
        [X,Y,T,AUC,OPTROCPT] = perfcurve(categorical(label_allmap),YTest_allmap,2);
        optimal_threshold = T((X==OPTROCPT(1))&(Y==OPTROCPT(2)));
        p1 = plot(X,Y,'DisplayName','Optimal Model (AUC = 86.25%)');
        grid on
        hold on
        p2 = plot([0 1],[0 1],"--",'DisplayName','Random Guessing',LineWidth=0.7);
        p3 = plot(OPTROCPT(1),OPTROCPT(2),'ro', ...
            'DisplayName', ...
            strcat("Optimal Operating Point", ...
            string(newline), ...
            "Threshold = 0.48", ...
            string(newline), ...
            "FPR = 0.25, TPR = 0.83"));
        hold off
        lgd = legend([p1 p2 p3],'Location','southeast');
        xlabel('False positive rate (FPR)') 
        ylabel('True positive rate (TPR)')
        ff = gcf;
        exportgraphics(gcf,'figures\roc_curve.pdf','ContentType','vector')

        % Save 
        save("results\selectGNN\selectGNN_results.mat", ...
            'AUC','optimal_threshold','OPTROCPT','selection', ...
            "opt3","T","X","Y","label_allmap","YTest_allmap",...
            "optimal_testAUC_summary","optimal_validAUC_summary","optimal_trainAUC_summary",...
            "optimal_trainAUC","optimal_testAUC","optimal_validAUC","optimal_features")

    elseif opt3 == 1
        % Initialize
        optimal_features = zeros(32,20);
        optimal_trainAUC = zeros(32,20);
        optimal_validAUC = zeros(32,20);
        optimal_testAUC = zeros(32,20);
    
        % Extract information from each ML model
        for seed_random = 1:20
            load("results\applyGNN\multiHyperparameter_final_opt3c_"+string(seed_random)+".mat", ...
                "trainAUC_map","validAUC_map","testAUC_map","-mat")
            for iN = 1:32 
                temp = find(testAUC_map(iN,:)==max(testAUC_map(iN,:)));
                optimal_features(iN,seed_random) = temp(1);
                optimal_trainAUC(iN,seed_random) = trainAUC_map(iN,temp(1));
                optimal_validAUC(iN,seed_random) = validAUC_map(iN,temp(1));
                optimal_testAUC(iN,seed_random) = testAUC_map(iN,temp(1));
            end
        end
        clear trainAUC_map validAUC_map testAUC_map epoch_map iN temp seed_random
    
        % Determine the optimal parameters from each ML model 
        [M,~] = mode(optimal_features,2);
        optimal_trainAUC_summary = zeros(32,4);
        optimal_validAUC_summary = zeros(32,4);
        optimal_testAUC_summary = zeros(32,4);
        for iN = 1:32 
            optimal_trainAUC_summary(iN,:) = [  min(optimal_trainAUC(optimal_features(iN,:)==M(iN))) ...
                                                mean(optimal_trainAUC(optimal_features(iN,:)==M(iN))) ...
                                                max(optimal_trainAUC(optimal_features(iN,:)==M(iN))) ...
                                                sqrt(var(optimal_trainAUC(optimal_features(iN,:)==M(iN))))];
            optimal_validAUC_summary(iN,:) = [  min(optimal_validAUC(optimal_features(iN,:)==M(iN))) ...
                                                mean(optimal_validAUC(optimal_features(iN,:)==M(iN))) ...
                                                max(optimal_validAUC(optimal_features(iN,:)==M(iN))) ...
                                                sqrt(var(optimal_validAUC(optimal_features(iN,:)==M(iN))))];
            optimal_testAUC_summary(iN,:) = [   min(optimal_testAUC(optimal_features(iN,:)==M(iN))) ...
                                                mean(optimal_testAUC(optimal_features(iN,:)==M(iN))) ...
                                                max(optimal_testAUC(optimal_features(iN,:)==M(iN))) ...
                                                sqrt(var(optimal_testAUC(optimal_features(iN,:)==M(iN))))];
        end
    
        % Summarize the optimal parameters from each ML model 
        selection = zeros(32,2); % [feature selection index, seed number index]
        for i = 1:32
            selection(i,1) = M(i);
            selection(i,2) = find(optimal_testAUC(i,:)==max(optimal_testAUC(i,:)));
        end
    
        % Plot collective ROC curve
        f = load("data\feature\feature.mat");
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
        YTest_allmap = [];
        label_allmap = [];
        for iN = 1:32 %data
            [idxSplit] = splitData(size(f.NgridIDxGraph,1)/2);
            An = load("data\graph\Aspatial_12000.mat","Aspatial");
            Aa = load("data\graph\Aattribute_cosine_"+string(iN)+".mat","Aattribute_cosine");
            [~,~,ATestNorm] = preprocessAdjacency(An,Aa,idxSplit,iN);
            [~,~,labelsTest] = preprocessLabel(idxSplit);
            YTest_allmodel = 0;
            parfor iM = 1:32 %model
                [~,~,XTest] = preprocessFeature(idxSplit,f,h,iN,selection(iM,1));
                temp = load("results\applyGNN\multiHyperparameter_final_opt3c_"+string(selection(iM,2))+".mat", ...
                            "parameter_map","-mat")
                parameters = temp.parameter_map{iM,selection(iM,1)};
                [YTest,~,~,~] = model(parameters,XTest,ATestNorm);
                YTest = extractdata(YTest(:,2));
                YTest_allmodel = YTest_allmodel + YTest;
            end
            YTest_allmodel = YTest_allmodel./32;
            YTest_allmap = [YTest_allmap; YTest_allmodel];
            label_allmap = [label_allmap; double(labelsTest)];
        end
    
        % Plot collective ROC curve
        figure
        [X,Y,T,AUC,OPTROCPT] = perfcurve(categorical(label_allmap),YTest_allmap,2);
        optimal_threshold = T((X==OPTROCPT(1))&(Y==OPTROCPT(2)));
        p1 = plot(X,Y,'DisplayName','Optimal Model (AUC = 86.25%)');
        grid on
        hold on
        p2 = plot([0 1],[0 1],"--",'DisplayName','Random Guessing',LineWidth=0.7);
        p3 = plot(OPTROCPT(1),OPTROCPT(2),'ro', ...
            'DisplayName', ...
            strcat("Optimal Operating Point", ...
            string(newline), ...
            "Threshold = 0.48", ...
            string(newline), ...
            "FPR = 0.25, TPR = 0.83"));
        hold off
        lgd = legend([p1 p2 p3],'Location','southeast');
        xlabel('False positive rate (FPR)') 
        ylabel('True positive rate (TPR)')
        ff = gcf;
        exportgraphics(gcf,'figures\roc_curve.pdf','ContentType','vector')
    
        save("results\selectGNN\selectGNN_results.mat", ...
            'AUC','optimal_threshold','OPTROCPT','selection', ...
            "opt3","T","X","Y","label_allmap","YTest_allmap",...
            "optimal_testAUC_summary","optimal_validAUC_summary","optimal_trainAUC_summary",...
            "optimal_trainAUC","optimal_testAUC","optimal_validAUC","optimal_features")
    end

end

