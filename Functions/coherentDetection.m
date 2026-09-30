function [Corr_max] = coherentDetection(rx_signal, pss_seq_freq, ph_offset)

PHO = exp(-1i*ph_offset*ones(length(rx_signal),1));
rx_signal_comp = PHO.*rx_signal;
Corr_max = filter(conj(flip(pss_seq_freq)),1,rx_signal_comp);

end

