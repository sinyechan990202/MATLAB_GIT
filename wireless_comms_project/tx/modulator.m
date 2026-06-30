function symbols = modulator(bits, modem)
% PSK/QAM symbol mapping with Gray coding

M   = modem.mod_order;
bps = log2(M);

% Pad to symbol boundary
rem = mod(length(bits), bps);
if rem > 0, bits = [bits(:); zeros(bps - rem, 1)]; end

symbols = qammod(bits(:), M, 'InputType', 'bit', ...
    'UnitAveragePower', true, 'PlotConstellation', false);
end
