function weights = initializeGlorot(sz,seed,numOut,numIn,className)

arguments
    sz
    seed
    numOut
    numIn
    className = 'single'
end

rng(seed,'Threefry');
Z = 2*rand(sz,className) - 1;
bound = sqrt(6 / (numIn + numOut));

weights = bound * Z;
weights = dlarray(weights);

end