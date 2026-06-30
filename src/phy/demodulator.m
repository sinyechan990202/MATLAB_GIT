function bits = demodulator(symbols, mod_scheme, noise_var)
% Demodulate complex symbols to bits (soft or hard decision)

switch upper(mod_scheme)
    case 'BPSK'
        bits = double(real(symbols) > 0);
    case 'QPSK'
        bits = qamdemod(symbols, 4, 'OutputType', 'bit', 'UnitAveragePower', true);
    case 'QAM16'
        bits = qamdemod(symbols, 16, 'OutputType', 'bit', 'UnitAveragePower', true, ...
            'NoiseVariance', noise_var);
    case 'QAM64'
        bits = qamdemod(symbols, 64, 'OutputType', 'bit', 'UnitAveragePower', true, ...
            'NoiseVariance', noise_var);
    otherwise
        error('Unsupported modulation scheme: %s', mod_scheme);
end
end
