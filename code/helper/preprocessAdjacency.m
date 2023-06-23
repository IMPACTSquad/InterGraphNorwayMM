function [ATrainNorm,AValidationNorm,ATestNorm] = preprocessAdjacency(An,Aa,idxSplit,iN)

    idxTrain = idxSplit.idxTrain;
    idxValidation = idxSplit.idxValidation;
    idxTest = idxSplit.idxTest;

    ATrain = (Aa.Aattribute_cosine(idxTrain,idxTrain)>0.5) ...
        & An.Aspatial{iN,1}(idxTrain,idxTrain);
    AValidation = (Aa.Aattribute_cosine(idxValidation,idxValidation)>0.5) ...
        & An.Aspatial{iN,1}(idxValidation,idxValidation);
    ATest = (Aa.Aattribute_cosine(idxTest,idxTest)>0.5) ...
        & An.Aspatial{iN,1}(idxTest,idxTest);
    
    ATrainNorm = normalizeAdjacency(ATrain);
    AValidationNorm = normalizeAdjacency(AValidation);
    ATestNorm = normalizeAdjacency(ATest);

end

