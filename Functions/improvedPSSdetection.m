function [ S_opt ] = improvedPSSdetection(rx_signal, pss_seq_freq, sigma_2, sigma2_ici, Nq, approxVer)

N = length(pss_seq_freq);

S_opt = zeros(size(rx_signal));
sigma_2 = max(sigma_2+sigma2_ici, 1e-1);

rx_signal = (1/sigma_2)*rx_signal;

phi_l = (pi/2)*(1:Nq-Nq/2)/Nq;
cos_l = cos(phi_l);
sin_l = sin(phi_l);

for i = 1:length(rx_signal)-N+1
    
    sequence_tilde = rx_signal(i:i+N-1);
    term1 = abs(sequence_tilde'*pss_seq_freq);
    
    if approxVer
    
        term2 = sum(abs(sequence_tilde));

    else

        r_I = real(sequence_tilde);
        r_Q = imag(sequence_tilde);
        r_ImQ = r_I - r_Q;
        r_IpQ = r_I + r_Q;
        r_QmI = r_Q - r_I;
        
        term2A = sum(abs((r_ImQ)*cos_l+(r_IpQ)*sin_l)/2,1);
        term2B = sum(abs((r_IpQ)*cos_l+(r_QmI)*sin_l)/2,1);
    
        term2 = max(term2A + term2B);

    end
    
    Lambda_3 = (term1 -  term2) ./ (term2 + eps) + 1;
    S_opt(i+N-1) = Lambda_3;

end

S_opt(1:N-1) = min(S_opt);

end
