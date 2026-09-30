function [correct, false, missed]  = evaluatePerformance_PeakDet_SSB(corrH0, corrH1,  threshold)
% 
num_slot = size(corrH0, 1);
% num_samples = size(corr.H0, 2);

correct = zeros(1, length(threshold));
false = zeros(1, length(threshold));

% Peak:
%peak_H0 = max([corr.H0]);
%corr_tot_with_PSS = [corr.H1(1:step_SSB:end), corr.H0(1:step_SSB:end,:)];
%max_H1 = max(corr.H1,[],2); %(1:step_SSB:end,:)
%max_H0 = max(corr.H0,[],2);
% For each instance take the peak, and compare it with a threshold
%above_thr = find(max(corr_tot_with_PSS,[],2) > threshold);
[peak, peak_ind] = max([corrH1, corrH0],[],2);
above_thr = peak > threshold;
if ~isempty(above_thr)
    if peak_ind == 1
        correct = above_thr;
    else
        false = above_thr;
    end
end
missed = (num_slot) - correct;

% % P(H1 | H1)
% prob_correct = correct / (1*num_slot);
% % P(H0 | H1)
% prob_missed = missed / (1*num_slot);
% % P(H1 | H0)
% prob_false = false /(num_samples*num_slot);

end