function [tx_signal, meta] = tx_top(n_bits, sys, modem)
% TX chain: bits → FEC → interleave → modulate → pilot insert → pulse shape → RF

bits                     = bit_source(n_bits, 'random');
coded                    = encoder(bits, modem);
[interleaved, meta.perm] = interleaver(coded, modem.block_len);
data_syms                = modulator(interleaved, modem);

%% Pilot insertion — pilot every sys.pilot_period data symbols
[tx_syms, pilot_mask] = insert_pilots(data_syms, sys.pilot_val, sys.pilot_period);
meta.pilot_mask       = pilot_mask;
meta.n_data_syms      = length(data_syms);

[shaped, meta.rrc] = pulse_shaping(tx_syms, sys, modem);
tx_signal          = rf_impairments(shaped, modem);

meta.tx_bits = bits;
meta.n_coded = length(coded);
meta.n_syms  = length(tx_syms);
end

function [out, mask] = insert_pilots(data, pilot_val, period)
% Interleave pilots: [P d1..dP  P d1..dP ...]
N_data   = length(data);
N_pilots = ceil(N_data / period);
N_total  = N_data + N_pilots;
out      = zeros(N_total, 1);
mask     = false(N_total, 1);

di = 1; ti = 1;
while di <= N_data
    out(ti)  = pilot_val;
    mask(ti) = true;
    ti = ti + 1;
    for k = 1:period
        if di <= N_data
            out(ti) = data(di);
            di = di + 1;
            ti = ti + 1;
        end
    end
end
out  = out(1:ti-1);
mask = mask(1:ti-1);
end
