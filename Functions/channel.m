function [rxWaveform, chan, ph_offset, iciRxWaveform ] = channel(txWaveform, chanType, No, delta_f, delta_ph, chan, seed, sampRate)

% Land Mobile Satellite (LMS) fading channel
if chanType == "LMS"
    % LMS channel
    release(chan);  
    % Set random number generator with seed
    chan.Seed = seed; rng(seed);
    % Pass the input signal through channel
    [outWaveform, channelCoefficients, sampleTimes, stateSeries] = step(chan, txWaveform.');
    outWaveform = outWaveform.';
else
    outWaveform = txWaveform;
end

% Additive White Gaussian Noise (AWGN)
noise = wgn(1,length(outWaveform), No,'linear','complex');
noiseWaveform = outWaveform+noise;

% Frequency offset insertion
N = linspace(0, length(noiseWaveform) - 1, length(noiseWaveform));
Ts = 1/sampRate;
FO = exp(1i*2*pi*delta_f*N*Ts);
rxWaveformFO = FO.*noiseWaveform; 

% Phase offset insertion
if delta_ph
    ph_offset = unifrnd(0,2*pi);
else
    ph_offset = 0;
end
PHO = exp(1i*ph_offset*ones(1,length(rxWaveformFO)));
rxWaveform = PHO.*rxWaveformFO;

%% for ICI estimation
iciRxWaveform = FO.*txWaveform;

end
