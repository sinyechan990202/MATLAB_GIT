% Unit test: MAC frame build / parse round-trip

addpath(genpath('../src'));

mac_cfg.preamble = [1 1 0 1 0 1 1 0 1 1 0 0 1 0 1 0]';
mac_cfg.header.src_id     = 5;
mac_cfg.header.dst_id     = 10;
mac_cfg.header.seq_num    = 42;
mac_cfg.header.frame_type = 1;

payload = randi([0 1], 256, 1);
frame   = frame_builder(payload, mac_cfg);
[rx_payload, hdr, crc_ok] = frame_parser(frame, mac_cfg);

assert(crc_ok,                   'CRC check failed');
assert(isequal(payload, rx_payload), 'Payload mismatch');
assert(hdr.src_id == 5,          'src_id mismatch');
assert(hdr.seq_num == 42,        'seq_num mismatch');
fprintf('[PASS] MAC frame build/parse round-trip\n');
