
%% 5G NR system parameters
fc = 1.6e9; % L-Band 1.6GHz
SCS = 30e3;
OFDM_symb_slot = 14;
NFFT  = 256;
sampRate = NFFT*SCS;
dataMod = "QPSK"; % BPSK or QPSK

%% Channel parameters
SNR_dB = [-4 -2 0 2];
chanType = "LMS"; % "AWGN" "LMS"
KFactor = 15; % Rician K factor [dB]
terminalSpeed = 5; % [km/h]
delta_f = [100];   % frequency Offset, [Hz]

%% Simulation and systems parameters
L = 1e3; % Total number of iterations (Total 5G slots)

delta_ph = true; % phase offset
extended = true; % use extended version
if extended
    Seq_len = 240;
else
    Seq_len = 127;
end
approxVer = false; % approximated version of PSS improved technique

% Synchronization can be:
% 0 - Peak Detection: look at the entire slot and take the max
% 1 - Sequential Frame Synchronization: hypothesis testing (Moving window)
synch_mode = 1;

% SSBs per slot (0, 1 or 2)
SSB_num = 1;

% Choose the system setting (SSB_flag)
% 0 - Only PSS and DATA
% 1 - 5G-like SSB and DATA
SSB_flag = 1;


