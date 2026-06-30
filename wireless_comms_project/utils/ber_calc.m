function [ber, ser, n_bit_err, n_sym_err] = ber_calc(tx_bits, rx_bits, bps)
% BER and SER calculation

n_bit_err = sum(tx_bits(:) ~= rx_bits(:));
ber       = n_bit_err / length(tx_bits(:));

% Group into symbols
n_sym     = floor(length(tx_bits) / bps);
tx_b = reshape(tx_bits(1:n_sym*bps), bps, n_sym);
rx_b = reshape(rx_bits(1:n_sym*bps), bps, n_sym);
n_sym_err = sum(any(tx_b ~= rx_b, 1));
ser       = n_sym_err / n_sym;
end
