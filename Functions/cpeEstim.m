function [cpe] = cpeEstim(iciRxSym, OFDM_sym)

cpe = mean(angle(iciRxSym.*conj(OFDM_sym)));

end