function [SSS_0] = Generate_SSS()

% 2 - SSS generation
% First LFSR state initialization
x0 = [1 0 0 0 0 0 0].';
% Second LFSR state initialization
x1 = [1 0 0 0 0 0 0].';
% Sequence generation
lseq = 127; % Sequence length
xseq_0 = zeros(1,lseq);
xseq_1 = zeros(1,lseq);
for m = 1 : lseq
    xseq_0(m) = x0(1); 
    xseq_1(m) = x1(1); 
    tmp0 = mod(x0(1)+x0(5),2);
    tmp1 = mod(x1(1)+x1(2),2);
    x0 = circshift(x0,-1);
    x1 = circshift(x1,-1);
    x0(7) = tmp0;
    x1(7) = tmp1;    
end
x0_out = xseq_0;
x1_out = xseq_1;
for NID2 = [0 1 2]
    for NID1 = [0 : 335]
        m0 = 15*floor(NID1/112)+5*NID2;
        m1 = mod(NID1,112);
        local_sss(NID2+1,NID1+1).SSS = (1 - 2*circshift(xseq_0.',-m0).').*(1 - 2*circshift(xseq_1.',-m1).');
    end
end
SSS_0 = local_sss(1,1).SSS;

end

