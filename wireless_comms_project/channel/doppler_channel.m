function [rx, fo_hz] = doppler_channel(tx, ch, sys)
% Apply Doppler frequency shift (항공·위성 시나리오)
%
% ch.doppler_hz    : Max Doppler (Hz)
% ch.velocity_mps  : Platform velocity
% sys.fs           : Sample rate

c      = 3e8;
fo_hz  = ch.doppler_hz;  % Use provided max Doppler

t = (0:length(tx)-1)' / sys.fs;
rx = tx .* exp(1j * 2 * pi * fo_hz * t);
end
