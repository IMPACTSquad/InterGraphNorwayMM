function [loss,gradients] = modelLoss(parameters,X,A,T)

    Y = model(parameters,X,A);
    loss = crossentropy(Y,T,1./(sum(T,1)/sum(sum(T))/min(sum(T,1)/sum(sum(T)))),'WeightsFormat','C',DataFormat="BC");
    gradients = dlgradient(loss, parameters);

end