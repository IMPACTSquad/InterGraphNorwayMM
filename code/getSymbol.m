function [symbol,count] = getSymbol(labelNum)

numSymbols = numel(labelNum);
symbol = strings(numSymbols, 1);
count = strings(numSymbols,1);

% lowCount = 0;
% highCount = 0;
q1Count = 0;
q2Count = 0;
q3Count = 0;
q4Count = 0;

    for i = 1:numSymbols
        if labelNum(i) <= 0.25
            symbol(i) = "a";
            q1Count = q1Count + 1;
            count(i) = "q1Count" + q1Count;
        elseif labelNum(i) > 0.25 && labelNum(i) <= 0.5
            symbol(i) = "b";
            q2Count = q2Count + 1;
            count(i) = "q2Count" + q2Count;
        elseif labelNum(i) > 0.5 && labelNum(i) <= 0.75
            symbol(i) = "c";
            q3Count = q3Count + 1;
            count(i) = "q3Count" + q3Count;
        else
            symbol(i) = "d";
            q4Count = q4Count + 1;
            count(i) = "q4Count" + q4Count;
        end
                % switch labelNum(i)
        %     case 0
        %         symbol(i) = "low";
        %         lowCount = lowCount + 1;
        %         count(i) = "low" + lowCount;
        %     case 1
        %         symbol(i) = "high";
        %         highCount = highCount + 1;
        %         count(i) = "high" + highCount;
        % end
    end

end
