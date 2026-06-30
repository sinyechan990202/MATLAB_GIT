function [tx_signal, meta] = tx_top(n_bits, sys, modem)
% TX chain: bits → FEC → interleave → modulate → pulse shape → RF impairments

bits          = bit_source(n_bits, 'random');
coded         = encoder(bits, modem);
[interleaved, meta.perm] = interleaver(coded, modem.block_len);
symbols       = modulator(interleaved, modem);
[shaped, meta.rrc] = pulse_shaping(symbols, sys, modem);
tx_signal     = rf_impairments(shaped, modem);

meta.tx_bits  = bits;
meta.n_coded  = length(coded);
meta.n_syms   = length(symbols);
end
