function [slot] = Generate_Input_Frequency_Domain(NFFT, OFDM, mod, SSB_num)

theta = pi/4; % pi/4;
tot_OFDM = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14];
switch SSB_num
    case 0
        data_OFDM = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14];
    case 1
        data_OFDM = [1, 2, 7, 8, 9, 10, 11, 12, 13, 14];
    case 2
        data_OFDM = [1, 2, 7, 8, 13, 14];
end
SSB_OFDM = setdiff(tot_OFDM, data_OFDM);

    % Generate DATA
    if mod == "BPSK"
        for i = data_OFDM
            OFDM(i, :) = exp(-1i*(theta + pi*(randi(2,1,NFFT)-1)));
            %(1-2*(randi(2,1,NFFT)-1));
        end
        for i = SSB_OFDM
            OFDM(i, [1:8, 249:NFFT]) = exp(-1i*(theta + pi*(randi(2,1,NFFT-240)-1)));
            %(1-2*(randi(2,1,NFFT-240)-1));
        end
    elseif mod == "QPSK"
        % Fullfil the OFDM symbols without SSB with random data
        OFDM(data_OFDM, :) = exp(-1i*(theta + pi/2*(randi(4,length(data_OFDM),NFFT)-1)));

        % Fullfil the border of the OFDM symbols with SSB in the center
        OFDM(SSB_OFDM, [1:8, 249:NFFT]) = exp(-1i*(theta + pi/2*(randi(4,length(SSB_OFDM),NFFT-240)-1)));

    end
    slot = OFDM;
    
%     figure; plot(slot,'o')
    %noise = randn(1, length(tx_signal))*sqrt(2*No);
end

%         for i = data_OFDM
%             rand_seq_I = (1-2*(randi(2,1,NFFT)-1));
%             rand_seq_Q = (1-2*(randi(2,1,NFFT)-1));
%             OFDM(i, :) = rand_seq_I + 1j*rand_seq_Q;
%             OFDM(i, :) = exp(-1i*((theta + pi/2*(randi(4,1,NFFT)-1))); %rand_seq_I + 1j*rand_seq_Q;
%         end

%         for i = SSB_OFDM
%             rand_seq_I = (1-2*(randi(2,1,NFFT-240)-1));
%             rand_seq_Q= (1-2*(randi(2,1,NFFT-240)-1));
%             OFDM(i, [1:8, 249:NFFT]) = rand_seq_I + 1j*rand_seq_Q;
%             OFDM(i, [1:8, 249:NFFT]) = exp(-1i*(theta + pi/2*(randi(4,1,NFFT-240)-1))); %rand_seq_I + 1j*rand_seq_Q;
%         end
