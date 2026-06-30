# Wireless Data Link System Design

## Architecture

```
[Application]
     |
[MAC Layer]  frame_builder / frame_parser / arq_controller / csma_ca
     |
[PHY Layer]  turbo_encoder → modulator → ofdm_modulate
     |
[Channel]    path_loss → rayleigh_channel → awgn_channel
     |
[PHY Layer]  ofdm_demodulate → demodulator → turbo_decoder
     |
[MAC Layer]  CRC check → ARQ feedback
```

## Standards Compliance

| Block            | Reference Standard        |
|------------------|--------------------------|
| OFDM             | IEEE 802.11a / 3GPP LTE  |
| Turbo Code       | 3GPP LTE TS 36.212       |
| ARQ              | IEEE 802.11 / 3GPP HARQ  |
| CSMA/CA          | IEEE 802.11 DCF           |
| Channel Model    | ITU-R M.1225 (EPA/EVA)   |
| Path Loss        | Okumura-Hata             |

## Key Parameters

- FFT Size: 64 (802.11a compatible)
- Cyclic Prefix: 16 samples (25%)
- Modulation: BPSK / QPSK / 16-QAM / 64-QAM
- Coding: Turbo code, rate 1/2
- ARQ: Selective-Repeat, max 4 retransmissions

## Running Simulations

```matlab
cd sim
run_ber_sim    % PHY BER sweep
run_ofdm_sim   % OFDM + Rayleigh BER sweep
run_link_sim   % Full MAC+PHY link simulation
```

## Running Tests

```matlab
cd test
test_modulation
test_ofdm
test_mac_frame
```
