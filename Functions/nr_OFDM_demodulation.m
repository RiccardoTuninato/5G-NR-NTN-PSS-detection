function [OFDMsymbol_time] = nr_OFDM_demodulation(rxWaveform, NFFT)

OFDMsymbol_time = zeros(14,NFFT);
for i = 1:size(OFDMsymbol_time,1)
    OFDMsymbol_time(i, :) = 1/sqrt(NFFT)*fftshift(fft(rxWaveform((i-1)*NFFT+1:i*NFFT)));
end

end