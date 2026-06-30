% Unit test: freq/timing/phase sync under mild impairments

addpath(genpath('../'));
run('../config/sys_params.m');
run('../config/modem_params.m');

modem.mod_order = 4; modem.bps = 2;
n_syms = 1000;
bits   = randi([0 1], n_syms * modem.bps, 1);
syms   = modulator(bits, modem);

% Pulse shape
[shaped, ~] = pulse_shaping(syms, sys, modem);

% Apply frequency offset
fo_test = 1000;  % Hz
t = (0:length(shaped)-1)' / sys.fs;
shaped_offset = shaped .* exp(1j * 2*pi * fo_test * t);

% Freq sync
[rx_synced, fo_est] = freq_sync(shaped_offset, sys, modem);
fprintf('Freq offset injected: %d Hz, estimated: %.1f Hz\n', fo_test, fo_est);
assert(abs(fo_est - fo_test) < fo_test * 0.1, 'Freq sync error > 10%%');

% Timing sync
[rx_syms, ~] = timing_sync(rx_synced, sys, modem);

% Phase sync
[rx_syms, ~] = phase_sync(rx_syms, modem);

fprintf('[PASS] Sync chain completed: %d symbols recovered\n', length(rx_syms));
