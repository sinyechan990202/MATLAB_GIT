% Unit test: modulator → demodulator round-trip (no channel)

addpath(genpath('../'));
run('../config/modem_params.m');

schemes = {struct('scheme','BPSK','mod_order',2,'bps',1,'fec_type','Conv','code_rate',1/2,'block_len',1024), ...
           struct('scheme','QPSK','mod_order',4,'bps',2,'fec_type','Conv','code_rate',1/2,'block_len',1024), ...
           struct('scheme','QAM16','mod_order',16,'bps',4,'fec_type','Conv','code_rate',1/2,'block_len',1024), ...
           struct('scheme','QAM64','mod_order',64,'bps',6,'fec_type','Conv','code_rate',1/2,'block_len',1024)};

for k = 1:length(schemes)
    m = schemes{k};
    bits = randi([0 1], 1000*m.bps, 1);
    syms = modulator(bits, m);
    [rx_bits, ~] = demodulator(syms, m, 0);
    rx_bits = rx_bits(1:length(bits));
    err = sum(bits ~= rx_bits);
    if err == 0
        fprintf('[PASS] %s\n', m.scheme);
    else
        fprintf('[FAIL] %s: %d errors\n', m.scheme, err);
    end
end
