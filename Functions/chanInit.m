function [chan] = chanInit(KFactor, fc, terminalSpeed, sampRate)

% LMS Channel

c = 3e8;

% For ITU-R P.681 LMS channel
chan = p681LMSChannel;
% Environment type
chan.Environment = 'custom'; %env.environment; %"Urban";
% Carrier frequency (in Hz)
chan.CarrierFrequency = fc; %3.8e9;
% Elevation angle with respect to ground plane (in degrees)
chan.ElevationAngle = 90; %env.elevationAngle; % 45;
% Speed of movement of ground terminal (in m/s)
chan.MobileSpeed = terminalSpeed * (1000/3600); %2;
% Direction of movement of ground terminal (in degrees)
chan.AzimuthOrientation = 0;

% Parameters for the states properties
% Parameters of state duration distribution in dB, specified as a 2-by-2 matrix
chan.StateDistribution = [1e2, 1e-5; 1e2, 1e0]; % [muG, muB; sigmaG, sigmaB]
% Minimum duration of each state in meters, specified as a two-element row vector. The first element corresponds to good state and the second element corresponds to bad state.
chan.MinStateDuration = [1e4, 1e-1]; % [G, B]

% Parameters of direct path amplitude distribution (dB)
chan.DirectPathDistribution = [0, 0; 0, 0]; % [muMaG, muMaB; sigmaMaG, sigmaMaB] Good = Bad

% Coefficients to compute the multipath power, specified as a 2-by-2 matrix
chan.MultipathPowerCoefficients = [0, 0; -KFactor, -KFactor]; %[0, 0; -env.KFactor, -env.KFactor];  %  [h1G, h1B; h2G, h2B] (default [-0.0481 0.9434; -14.7450 -1.7555])
% Coefficients to compute standard deviation of direct path amplitude in all states, specified as a 2-by-2 matrix
chan.StandardDeviationCoefficients = [0, 0; 0, 0];  %  [g1G, g1B; g2G, g2B]

% Direct path amplitude correlation distance (m)
L_corr = 7.9; %10; % default [1.7910 1.7910] 7.9
chan.TransitionLengthCoefficients = [0; 0];
chan.DirectPathCorrelationDistance = [L_corr, L_corr];
chan.StateProbabilityRange = [1e-5, 1e-5; 1-1e-5, 1-1e-5];


chan.RandomStream = "mt19937ar with seed";

% Sampling rate (in Hz)
chan.SampleRate = sampRate; %400;

chan.InitialState = "Good";
chan.FadingTechnique = "Filtered Gaussian noise"; 

chan.ChannelFiltering = true;

    
% Set random number generator with seed
chan.Seed = 0; rng(0);

end