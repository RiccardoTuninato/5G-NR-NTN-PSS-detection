function [slot] = Generate_slot_SSB(NFFT, SSB_num, SSB_flag, dataMod)
    
PSS_0 = Generate_PSS();
SSS_0 = Generate_SSS();

SSB_bw = 240; % SSB subcarriers occupancy
frame = length(PSS_0);

% DMRS Sequence Generation (not used in this version)
CELL_ID = 0*3 + 0;
ibar_SSB = 0;
v = mod(CELL_ID, 4);
DMRS_SEQ = nrPBCHDMRS(CELL_ID,ibar_SSB);

% Fulfil the subcarriers around PSS
padding_left_PSS = zeros(1,floor((NFFT-frame)/2));
padding_right_PSS = zeros(1,floor((NFFT-frame)/2)+1);

% Pre-allocation
OFDM = zeros(14, NFFT); 
for i = 0:13
    OFDM(i+1, :) =  zeros(1, NFFT);
end

% Generate the frequency domain SSB
padding_SSB = zeros(1,(NFFT - 240)/2);
theta = pi/4; % pi/4;


for i = 1:SSB_num

    if SSB_flag == 1

        SSB_partial_bw = floor((SSB_bw-frame)/2);

        PBCH_1 = exp(-1i*(pi/4 + pi/2*(randi(4,1,SSB_bw)-1)));
        PBCH_2 = exp(-1i*(pi/4 + pi/2*(randi(4,1,SSB_partial_bw)-1)));
        PBCH_3 = exp(-1i*(pi/4 + pi/2*(randi(4,1,SSB_partial_bw)-1)));
        PBCH_4 = exp(-1i*(pi/4 + pi/2*(randi(4,1,SSB_bw)-1)));

        SSB_0 = [padding_left_PSS PSS_0 padding_right_PSS];
        SSB_1 = [padding_SSB PBCH_1 padding_SSB];
        SSB_2 = [padding_SSB PBCH_2 SSS_0 0 PBCH_3 padding_SSB];
        SSB_3 = [padding_SSB PBCH_4 padding_SSB];

    elseif SSB_flag == 0 
        
        % Insert only the PSS in the SSB
        SSB_0 = [padding_left_PSS PSS_0 padding_right_PSS];
        if dataMod == "BPSK"
           SSB_1 = [padding_SSB exp(-1i*(pi*(randi(2,1,SSB_bw)-1))) padding_SSB];
           SSB_2 = [padding_SSB exp(-1i*(pi*(randi(2,1,SSB_bw)-1))) padding_SSB];
           SSB_3 = [padding_SSB exp(-1i*(pi*(randi(2,1,SSB_bw)-1))) padding_SSB];
        elseif dataMod == "QPSK"
           SSB_1 = [padding_SSB exp(-1i*(pi/4 + pi/2*(randi(4,1,SSB_bw)-1))) padding_SSB];
           SSB_2 = [padding_SSB exp(-1i*(pi/4 + pi/2*(randi(4,1,SSB_bw)-1))) padding_SSB];
           SSB_3 = [padding_SSB exp(-1i*(pi/4 + pi/2*(randi(4,1,SSB_bw)-1))) padding_SSB];  
        end

    end

    OFDM(3+(i-1)*6:6+(i-1)*6, :) = [SSB_0; SSB_1; SSB_2; SSB_3];

end
slot = OFDM;
%figure; plot(slot,'o')

end

