function [PSS_0] = Generate_PSS()

% 1 -PSS
frame = 127;
L_register=5; %7; % numero celle
Nb=2^L_register-1; % numero di bit sequenza base
pnSequence = comm.PNSequence('Polynomial',[7 4 0], ...
    'SamplesPerFrame',frame,'InitialConditions',[1 1 1 0 1 1 0]);
M_seq = pnSequence()';
PSS_0 = 2*M_seq-1;

end

