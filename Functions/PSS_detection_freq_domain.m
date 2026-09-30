function [metricsTech, Thresholds] = ...
    PSS_detection_freq_domain(rxSlot, NFFT, sigma2,  Thr_points, ...
                ext, n_slot, synch_mode, ph_offset, metricsTech, Thresholds, sigma2_ici, approxVer)

PSS_local_0 = Generate_PSS().';
%PSS_local_0 = circshift(PSS_local_0,0);
frame = length(PSS_local_0);

if ext
    seq_len = 240;
    padding_left=zeros(floor((seq_len-frame)/2), 1);
    padding_right=zeros(floor((seq_len-frame)/2)+1, 1);
    PSS_local_0 = [padding_left; PSS_local_0; padding_right];
else
    seq_len = frame;
end
filter_delay =seq_len-1;

rx_SSB_freq = reshape(transpose(rxSlot),[],1);

%% Detection techniques

Nq = 4;
improvedTech = improvedPSSdetection(rx_SSB_freq, PSS_local_0, sigma2, sigma2_ici, Nq, approxVer);
UncoherentCorr = abs(filter(conj(flip(PSS_local_0)),1,conj(rx_SSB_freq.')).');
Trip_autocorr = Triple_autocorr(rx_SSB_freq, frame, seq_len);
CoherentCorr = coherentDetection(rx_SSB_freq, PSS_local_0, ph_offset);

%% Compute metrics

PSS_pos = 9+NFFT*2+filter_delay;
extLen = ceil((seq_len-frame)/2);
dataRange = [filter_delay:PSS_pos-1-NFFT/2 PSS_pos+1+NFFT/2:length(improvedTech)];

CorrH1_Tech1 = improvedTech(PSS_pos);
CorrH1_Tech2 = UncoherentCorr(PSS_pos);
CorrH1_Tech3 = Trip_autocorr(PSS_pos-extLen);
CorrH1_Tech4 = CoherentCorr(PSS_pos);

if synch_mode == 0
    % Peak detection (take the max)
    CorrH0_Tech1 = max(improvedTech(dataRange));
    CorrH0_Tech2 = max(UncoherentCorr(dataRange));
    CorrH0_Tech3 = max(Trip_autocorr([filter_delay:PSS_pos-1-extLen-NFFT/2 PSS_pos-extLen+1+NFFT/2:end]));
    CorrH0_Tech4 = max(CoherentCorr(dataRange));
else
    % Hypothesis testing (take all the correlation values)
    CorrH0_Tech1 = improvedTech(dataRange);
    CorrH0_Tech2 = UncoherentCorr(dataRange);
    CorrH0_Tech3 = Trip_autocorr([filter_delay:PSS_pos-1-extLen-NFFT/2 PSS_pos-extLen+1+NFFT/2:end]);
    CorrH0_Tech4 = CoherentCorr(dataRange);
end

if n_slot == 1
    Thresholds(1, :) = linspace(0, max(abs(improvedTech))*1.2,Thr_points);
    Thresholds(2, :) = linspace(0, max(abs(UncoherentCorr))*1.2,Thr_points);
    Thresholds(3, :) = linspace(0, max(abs(Trip_autocorr))*1.15,Thr_points);
    Thresholds(4, :) = linspace(0, max(abs(CoherentCorr))*1.15,Thr_points);
end

metricsTech{1} = computeDetMetrics(CorrH0_Tech1, CorrH1_Tech1, Thresholds(1,:), metricsTech{1}, synch_mode, n_slot);
metricsTech{2} = computeDetMetrics(CorrH0_Tech2, CorrH1_Tech2, Thresholds(2,:), metricsTech{2}, synch_mode, n_slot);
metricsTech{3} = computeDetMetrics(CorrH0_Tech3, CorrH1_Tech3, Thresholds(3,:), metricsTech{3}, synch_mode, n_slot);
metricsTech{4} = computeDetMetrics(CorrH0_Tech4, CorrH1_Tech4, Thresholds(4,:), metricsTech{4}, synch_mode, n_slot);

%{
figure;plot(improvedTech)
figure;plot(UncoherentCorr)
%figure;plot(real(Trip_autocorr))
%figure;plot(real(CoherentCorr))
%}

end


