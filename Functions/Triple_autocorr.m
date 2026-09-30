function [tri_auto] = Triple_autocorr(rx_signal, frame, seq_len)

N = frame;

vec_p = [1 2 3 6 9 10 11 12 15 17 20 21 22 24 25 26 33 36 38 39 41 42 43 45 ...
    46 47 48 51 52 53 54 58 59 61 64];
vec_q = [30 60 4 8 35 27 23 16 48 52 54 19 46 32 64 29 51 13 47 18 25 38 33 ...
    5 59 42 64 43 58 20 53 17 22 41 15];

trials = length(vec_p);
max_shift = max(vec_p);

x = zeros(N, 1);

pair_pq = 1;
p = vec_p(pair_pq);
q = vec_q(pair_pq);

tri_auto = zeros(length(rx_signal), 1);
        
for  i = 1:length(rx_signal)-N-1 
    
    x = rx_signal(i:N+i-1);

        x_p = circshift(x, -p);  x_q = circshift(x, q);
        tri_auto(i+N-1) = abs(sum(x.*x_p.*x_q));

end


end