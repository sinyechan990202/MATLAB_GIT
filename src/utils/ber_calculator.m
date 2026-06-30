function [ber, n_errors] = ber_calculator(tx_bits, rx_bits)
% Compute BER and error count

n_errors = sum(tx_bits(:) ~= rx_bits(:));
ber      = n_errors / length(tx_bits(:));
end
