function [adjacency,features,labels] = preprocessData(adjacencyData,featureData,labelData,lenlabelData)
    
    [adjacency, features] = preprocessPredictors(adjacencyData,featureData);
    labels = [];
    
    % Convert labels to categorical.
    for i = 1:size(adjacencyData,3)
        % Extract and append unpadded data.
        T = labelData(i,1:lenlabelData(i))';
        labels = [labels; T];
    end
    
    labelNumbers = unique(labels);
    labelNames =  getSymbol(labelNumbers);
    labels = categorical(labels, labelNumbers, labelNames);

end