function symbols = modulator(bits, mod_scheme)
% Modulate bits to complex symbols
% Supports: 'BPSK', 'QPSK', 'QAM16', 'QAM64'

switch upper(mod_scheme)
    case 'BPSK'
        symbols = 2*bits - 1;
    case 'QPSK'
        symbols = qammod(bits, 4, 'InputType', 'bit', 'UnitAveragePower', true);
    case 'QAM16'
        symbols = qammod(bits, 16, 'InputType', 'bit', 'UnitAveragePower', true);
    case 'QAM64'
        symbols = qammod(bits, 64, 'InputType', 'bit', 'UnitAveragePower', true);
    otherwise
        error('Unsupported modulation scheme: %s', mod_scheme);
end
end
