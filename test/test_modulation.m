% Unit test: modulator / demodulator round-trip

addpath(genpath('../src'));

schemes = {'BPSK', 'QPSK', 'QAM16', 'QAM64'};
pass = true;

for k = 1:length(schemes)
    scheme = schemes{k};
    bps = log2(str2double(regexp(scheme, '\d+', 'match', 'once')));
    if isnan(bps), bps = 1; end  % BPSK

    n_bits = 1000 * bps;
    bits = randi([0 1], n_bits, 1);
    sym  = modulator(bits, scheme);
    rx   = demodulator(sym, scheme, 0);

    err = sum(bits ~= rx);
    if err == 0
        fprintf('[PASS] %s\n', scheme);
    else
        fprintf('[FAIL] %s: %d errors\n', scheme, err);
        pass = false;
    end
end

assert(pass, 'Modulation round-trip test failed');
