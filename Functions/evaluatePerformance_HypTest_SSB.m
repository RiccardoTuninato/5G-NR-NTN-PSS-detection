function [correct, false, missed]  = evaluatePerformance_HypTest_SSB(corrH0, corrH1, threshold)

% Considering both slots with SSB
correct = corrH1 > threshold;
missed = size(corrH0, 1) - correct;
false = sum(corrH0 >= threshold, 1);

end
    