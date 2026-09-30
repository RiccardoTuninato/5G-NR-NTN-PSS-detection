function [] = PSSsynch_5GNR(L, SNR_dB, delta_f, delta_ph, ...
    dataMod, extended, synch_mode, Seq_len, SSB_num, ...
    fc, chanType, KFactor, SCS, sampRate, terminalSpeed, NFFT, SSB_flag,approxVer)

disp("SNR: "+SNR_dB+" [dB]");

% Parameters for performance evaluation
Thr_points = 1e3;
for t = 1:4
    metricsTech{t}.correct_count_SSB = zeros(1, Thr_points);
    metricsTech{t}.false_count_SSB = zeros(1, Thr_points);
    metricsTech{t}.missed_count_SSB = zeros(1, Thr_points);
end
Thresholds = zeros(4, Thr_points);

No = 10^(-SNR_dB/10.0);

rand(1);

if chanType == "LMS"
    chan = chanInit(KFactor, fc, terminalSpeed, sampRate);
else
    chan = [];
end

for n_slot = 1:L
        
    if SSB_num ~= 0
        [SSB_symbols] = Generate_slot_SSB(NFFT, SSB_num, SSB_flag, dataMod);
    end
    
    % Generate a single slot ( = 14 OFDM symbols) allocating the data to the empty subcarriers in the frequency domain
    [OFDM_symbols] = Generate_Input_Frequency_Domain(NFFT, SSB_symbols, dataMod, SSB_num);

    %% OFDM MODULATION
    txWaveform = nr_OFDM_modulation(OFDM_symbols, NFFT);

    %% CHANNEL
    seed = n_slot+100;
    [rxWaveform, chan, ph_offset, iciRxWaveform] = channel(txWaveform, chanType, No, delta_f, delta_ph, chan, seed, sampRate);
    
    %% OFDM DEMODULATION
    rxSlot = nr_OFDM_demodulation(rxWaveform, NFFT);

    if n_slot == 1
        sigma2_ici = iciEstimation(iciRxWaveform, OFDM_symbols, NFFT);
    end
    
    %% PSS DETECTION
    [metricsTech, Thresholds] = PSS_detection_freq_domain(rxSlot, NFFT, No, Thr_points, ...
        extended, n_slot, synch_mode, ph_offset, metricsTech, Thresholds, sigma2_ici, approxVer); 
    
    if mod(n_slot, L*0.1) == 0
        disp("Simulation at "+n_slot/L*100+" %");
    end
    
end


%% Save the results in a file

switch synch_mode
    case 0
        file = "Results/PSSsyncNTN_PeakDet";
    case 1
        file = "Results/PSSsyncNTN_HypTest";
end

if chanType ~= "LMS"
    file = strcat(file,"_SCS_%d_CFO_%.3d_seqlen_%.3d_SNR%.2f.mat");
else
    file = strcat(file,"_SCS_%d_CFO_%.3d_seqlen_%.3d_SNR%.2f_chanLMS_K"+KFactor+"_S"+int16(terminalSpeed)+".mat");
end

filename = sprintf(file, SCS/1e3, delta_f, Seq_len, SNR_dB);        

save(filename, 'metricsTech', 'L','SNR_dB','delta_f', 'extended', 'SCS', ...
    'chanType', 'KFactor', 'terminalSpeed', 'NFFT', 'sampRate', 'Seq_len', ...
    'delta_ph', 'SSB_flag', 'SSB_num', 'Thresholds', 'dataMod', 'synch_mode');

end



