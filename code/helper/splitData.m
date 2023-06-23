function [idxSplit] = splitData(n)

    rng(1,'Threefry');

    nonlabel_i = randperm(n,n);
    label_i = randperm(n,n) + n;
    [a, b, c] = dividerand(n, 0.7, 0.15, 0.15);

    idxSplit.idxTrain = [nonlabel_i(a)'; label_i(a)'];
    idxSplit.idxValidation = [nonlabel_i(b)'; label_i(b)'];
    idxSplit.idxTest = [nonlabel_i(c)'; label_i(c)'];

end

