function frame = frame_builder(payload, cfg)
% Build MAC frame: Preamble | Header | Payload | CRC
%
% cfg fields:
%   preamble    - Known sync sequence
%   header      - struct with src_id, dst_id, seq_num, frame_type

preamble  = cfg.preamble(:);
header    = build_header(cfg.header);
crc       = compute_crc(payload, 32);

frame = [preamble; header; payload(:); crc];
end

function hdr_bits = build_header(hdr)
% 32-bit header: [src_id(8) dst_id(8) seq_num(8) frame_type(8)]
fields = [hdr.src_id, hdr.dst_id, hdr.seq_num, hdr.frame_type];
hdr_bits = de2bi(fields, 8, 'left-msb')';
hdr_bits = hdr_bits(:);
end

function crc_bits = compute_crc(data, poly_order)
gen = crcgenerator(poly_order);
crc_bits = generate(gen, data(:));
end
