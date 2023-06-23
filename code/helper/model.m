function [Y, Z, Yprime, Zprime] = model(parameters,X,ANorm)
    
    % neural network
    Z1 = X;
    Z2 = ANorm * Z1 * parameters.mult1.Weights;
    Z2 = relu(Z2); 
    Z3 = ANorm * Z2 * parameters.mult2.Weights;
    Z3 = relu(Z3) + Z2;
    Z4 = ANorm * Z3 * parameters.mult3.Weights;
    Z4 = relu(Z4) + Z3;
    Z5 = ANorm * Z4 * parameters.mult4.Weights;
    Z5 = relu(Z5) + Z4; 
    Z6 = ANorm * Z5 * parameters.mult5.Weights;
    Z6 = relu(Z6) + Z5; 
    Z7 = ANorm * Z6 * parameters.mult6.Weights;
    Z7 = relu(Z7) + Z6; 
    Z8 = ANorm * Z7 * parameters.mult7.Weights;
    p = 1./(1+exp(-Z8));
    Y = [1-p p];
    
    % regularization
    Z = Z8;
    Zprime = ANorm * Z;
    pprime = 1./(1+exp(-Zprime));
    Yprime = [1-pprime pprime];
  
end