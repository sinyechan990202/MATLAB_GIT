function out = snr_converter(val, from, to, bits_per_sym)
% Convert between Eb/N0, Es/N0, SNR (all in dB)
%
% from/to: 'EbN0' | 'EsN0' | 'SNR'
% bits_per_sym: log2(modulation order)

bps = bits_per_sym;
switch [upper(from) '->' upper(to)]
    case 'EBN0->ESN0'
        out = val + 10*log10(bps);
    case 'ESN0->EBN0'
        out = val - 10*log10(bps);
    case 'ESN0->SNR'
        out = val;  % equal when bandwidth = symbol rate
    case 'EBN0->SNR'
        out = val + 10*log10(bps);
    otherwise
        error('Unsupported conversion: %s -> %s', from, to);
end
end
