function rx = awgn_channel(tx, snr_db)
% Add AWGN given Eb/N0 in dB (power measured from signal)
rx = awgn(tx, snr_db, 'measured');
end
