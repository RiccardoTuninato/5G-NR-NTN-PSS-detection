%% 5G NR SYNCRHONIZATION PROCEDURE

% From: R. Tuninato and R. Garello, "5G NTN Primary Synchronization Signal: An Improved Detector for Handheld Devices," 
% in IEEE Open Journal of the Communications Society, vol. 5, pp. 3792-3803, 2024, doi: 10.1109/OJCOMS.2024.3416554

% Description:
% In this program we simulate the generation of a 5G NR signal,
% containing only the Synchronization Signal Block (SSB), the structure
% which contains the Primary and the Secondary Synchronization Signal
% (PSS and SSS), and the Physical Broadcast Channel (PBCH), with its
% associated DMRS (Demodulation Reference Signal).
% The signal is transmitted through an Land Mobile Satellite (LMS) or
% Additive White Gaussian Noise (AWGN) channel, and then received by
% the user.
% At the receiver side, we must detect the PSS.

%% 
clc
clear
close all

addpath Functions

loadSysParams

disp("Date: "+ datestr(datetime)+" | Simulation of "+L+" iterations | Synch seq length: "+Seq_len+".");
disp("CFO: "+delta_f+" Hz | Phase offset: "+delta_ph+" | Data Modulation: "+dataMod+".");
disp("Synch mode: "+synch_mode+" | Number of SSB per slot: "+SSB_num+".");
if chanType == "LMS"
    disp("Channel: "+chanType+" K factor "+KFactor+"."+" terminal speed "+terminalSpeed+" km/h.");
end


for n_snr = 1:length(SNR_dB)   
    for n_CFO = 1:length(delta_f)
        PSSsynch_5GNR(L, SNR_dB(n_snr), delta_f(n_CFO), ...
            delta_ph, dataMod, extended, synch_mode, Seq_len, ...
            SSB_num, fc, chanType, KFactor, SCS, ...
            sampRate, terminalSpeed, NFFT, SSB_flag, approxVer);
    end
end
