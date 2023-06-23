function [loss,gradients] = modelLoss(parameters,X,ANorm,T)

    [Y, ~, Yprime, ~] = model(parameters,X,ANorm);
    
    loss = crossentropy(Y,T,DataFormat="BC") ...
            + crossentropy(Yprime,Y,DataFormat="BC");
    gradients = dlgradient(loss, parameters);

end
