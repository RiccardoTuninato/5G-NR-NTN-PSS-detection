function [metricsTech] = computeDetMetrics(corrH0, corrH1, Thresholds, ...
    metricsTech, synch_mode, n_slot)

%for j = 1:size(Thresholds, 2)
    if synch_mode == 0
        [correct_c_temp_SSB, false_c_temp_SSB, missed_c_temp_SSB] = ...
            evaluatePerformance_PeakDet_SSB(corrH0, corrH1, Thresholds); 
    elseif synch_mode == 1
        [correct_c_temp_SSB, false_c_temp_SSB, missed_c_temp_SSB] = ...
            evaluatePerformance_HypTest_SSB(corrH0, corrH1, Thresholds);
    end
%end

% metricsTech(n_slot, :).correct_count_SSB = correct_c_temp_SSB; 
% metricsTech(n_slot, :).false_count_SSB = false_c_temp_SSB;
% metricsTech(n_slot, :).missed_count_SSB = missed_c_temp_SSB;

metricsTech.correct_count_SSB = metricsTech.correct_count_SSB + correct_c_temp_SSB; 
metricsTech.false_count_SSB = metricsTech.false_count_SSB + false_c_temp_SSB;
metricsTech.missed_count_SSB = metricsTech.missed_count_SSB + missed_c_temp_SSB;

end