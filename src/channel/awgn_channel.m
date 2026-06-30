function rx_signal = awgn_channel(tx_signal, snr_db)
% Add AWGN noise given SNR in dB (per symbol)
rx_signal = awgn(tx_signal, snr_db, 'measured');
end
