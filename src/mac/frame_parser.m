function [payload, header, crc_ok] = frame_parser(frame, cfg)
% Parse received MAC frame and verify CRC

preamble_len = length(cfg.preamble);
header_len   = 32;   % bits
crc_len      = 32;   % bits

header_bits = frame(preamble_len + 1 : preamble_len + header_len);
header      = parse_header(header_bits);

payload_end = length(frame) - crc_len;
payload     = frame(preamble_len + header_len + 1 : payload_end);

rx_crc      = frame(payload_end + 1 : end);
exp_crc     = compute_crc(payload, 32);
crc_ok      = isequal(rx_crc, exp_crc);
end

function hdr = parse_header(bits)
bits = reshape(bits, 8, 4);
vals = bi2de(bits', 'left-msb');
hdr.src_id     = vals(1);
hdr.dst_id     = vals(2);
hdr.seq_num    = vals(3);
hdr.frame_type = vals(4);
end

function crc_bits = compute_crc(data, poly_order)
gen = crcgenerator(poly_order);
crc_bits = generate(gen, data(:));
end
