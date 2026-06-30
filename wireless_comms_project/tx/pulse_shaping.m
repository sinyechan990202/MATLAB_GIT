function [tx_signal, rrc_filt] = pulse_shaping(symbols, sys, modem)
% Root-Raised Cosine pulse shaping filter

rrc_filt = rcosdesign(modem.rolloff, modem.filt_span, sys.sps, 'sqrt');

% Upsample and filter
upsampled = upsample(symbols, sys.sps);
tx_signal = filter(rrc_filt, 1, upsampled);

% Remove filter transient
delay = floor(modem.filt_span * sys.sps / 2);
tx_signal = tx_signal(delay+1:end);
end
