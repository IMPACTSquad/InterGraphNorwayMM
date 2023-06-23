function [labelsTrain,labelsValidation,labelsTest] = preprocessLabel(idxSplit)

    idxTrain = idxSplit.idxTrain;
    idxValidation = idxSplit.idxValidation;
    idxTest = idxSplit.idxTest;

    labelsTrain = categorical([repelem(1,numel(idxTrain)/2)';repelem(0,numel(idxTrain)/2)']);
    labelsValidation = categorical([repelem(1,numel(idxValidation)/2)';repelem(0,numel(idxValidation)/2)']);
    labelsTest = categorical([repelem(1,numel(idxTest)/2)';repelem(0,numel(idxTest)/2)']);
    
end

