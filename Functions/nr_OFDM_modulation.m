function [txWaveform] = nr_OFDM_modulation(slot, NFFT)

OFDMsym = zeros(14, NFFT);
for i = 1:size(slot,1)
    OFDMsymbol_time = sqrt(NFFT)*ifft(ifftshift(slot(i,:)));
    txWaveform((i-1)*256+1:i*256) = OFDMsymbol_time;
end

end