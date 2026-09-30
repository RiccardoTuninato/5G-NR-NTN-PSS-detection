function [sigma_2_ici] = iciEstimation(iciRxWaveform, OFDM_symbols,  NFFT)

% Data-genie-aided ICI variance estimation
% Over 1 OFDM symbol

iciRxSlot = nr_OFDM_demodulation(iciRxWaveform, NFFT);

cpe = mean(angle(iciRxSlot(1,:).*conj(OFDM_symbols(1,:))));
iciRxSlotCPEcomp = iciRxSlot(1,:)*exp(-1j*cpe);

ici = iciRxSlotCPEcomp-OFDM_symbols(1,:);
sigma_2_ici = var(ici, [], 'all');


end