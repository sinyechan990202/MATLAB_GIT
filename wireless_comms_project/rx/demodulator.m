function [bits, llr] = demodulator(symbols, modem, noise_var)
% Symbol demapping with LLR output for soft-decision FEC

M = modem.mod_order;

if nargin < 3 || isempty(noise_var)
    noise_var = 0.1;
end

llr  = qamdemod(symbols, M, 'OutputType', 'llr', ...
    'UnitAveragePower', true, 'NoiseVariance', noise_var);
bits = double(llr < 0);  % hard decision from LLR sign
end
