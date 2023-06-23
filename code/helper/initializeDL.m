function [parameters] = initializeDL(numInputFeatures,labelsTrain,seed_random)

    parameters = struct;
    numHiddenFeatureMaps = 240;
    
    sz = [numInputFeatures numHiddenFeatureMaps];
    numOut = numHiddenFeatureMaps;
    numIn = numInputFeatures;
    parameters.mult1.Weights = initializeGlorot(sz,seed_random,numOut,numIn,"double");
    
    sz = [numHiddenFeatureMaps numHiddenFeatureMaps];
    numOut = numHiddenFeatureMaps;
    numIn = numHiddenFeatureMaps;
    parameters.mult2.Weights = initializeGlorot(sz,seed_random,numOut,numIn,"double");
    
    sz = [numHiddenFeatureMaps numHiddenFeatureMaps];
    numOut = numHiddenFeatureMaps;
    numIn = numHiddenFeatureMaps;
    parameters.mult3.Weights = initializeGlorot(sz,seed_random,numOut,numIn,"double");
    
    sz = [numHiddenFeatureMaps numHiddenFeatureMaps];
    numOut = numHiddenFeatureMaps;
    numIn = numHiddenFeatureMaps;
    parameters.mult4.Weights = initializeGlorot(sz,seed_random,numOut,numIn,"double");
    
    sz = [numHiddenFeatureMaps numHiddenFeatureMaps];
    numOut = numHiddenFeatureMaps;
    numIn = numHiddenFeatureMaps;
    parameters.mult5.Weights = initializeGlorot(sz,seed_random,numOut,numIn,"double");
    
    sz = [numHiddenFeatureMaps numHiddenFeatureMaps];
    numOut = numHiddenFeatureMaps;
    numIn = numHiddenFeatureMaps;
    parameters.mult6.Weights = initializeGlorot(sz,seed_random,numOut,numIn,"double");
    
    classes = categories(labelsTrain);
    numClasses = numel(classes);
    sz = [numHiddenFeatureMaps 1];
    numOut = 1;
    numIn = numHiddenFeatureMaps;
    parameters.mult7.Weights = initializeGlorot(sz,seed_random,numOut,numIn,"double");

end

