# Wireless Communications System — MATLAB Simulation

무선 통신 시스템의 PHY/채널 모델링 및 성능 분석을 위한 MATLAB 시뮬레이션 프레임워크입니다.  
항공·위성 시나리오(도플러, 멀티패스, 링크버짓)를 포함한 실무 기준 구조로 설계되었습니다.

---

## 프로젝트 구조

```
wireless_comms_project/
├── main.m                        # 전체 BER 시뮬레이션 엔트리포인트
│
├── config/
│   ├── sys_params.m              # 시스템 파라미터 (fs, fc, SNR 범위, 파일럿)
│   ├── channel_params.m          # 채널 파라미터 (도플러, ITU 지연 프로파일, 위성 궤도)
│   └── modem_params.m            # 변조 파라미터 (변조차수, FEC, RRC 롤오프, RF 불균형)
│
├── tx/                           # 송신 체인
│   ├── tx_top.m                  # TX 최상위 (체인 전체 호출)
│   ├── bit_source.m              # 랜덤/파일 비트 생성
│   ├── modulator.m               # PSK/QAM Gray 부호 심볼 매핑
│   ├── pulse_shaping.m           # RRC 펄스 성형 필터 (업샘플링 포함)
│   ├── rf_impairments.m          # IQ 불균형, 위상잡음, DC 오프셋
│   └── fec/
│       ├── encoder.m             # FEC 인코더 (LDPC / Turbo / Conv)
│       └── interleaver.m         # 비트 인터리버 (블록 / 랜덤)
│
├── channel/                      # 채널 모델
│   ├── channel_top.m             # 채널 체인 최상위 (멀티패스→도플러→AWGN)
│   ├── awgn_channel.m            # AWGN 채널
│   ├── doppler_channel.m         # 도플러 주파수 편이 (항공·위성 시나리오)
│   ├── multipath_channel.m       # 주파수 선택성 채널 (ITU EPA/EVA/ETU 프로파일)
│   └── satellite_link_budget.m   # 위성 링크버짓 (EIRP/FSPL/G·T/C·N0/섀넌 용량)
│
├── rx/                           # 수신 체인
│   ├── rx_top.m                  # RX 최상위 (체인 전체 호출)
│   ├── agc.m                     # 자동이득제어 (전력 정규화)
│   ├── channel_estimator.m       # 파일럿 기반 채널 추정 (LS / MMSE)
│   ├── equalizer.m               # 주파수 영역 등화기 (ZF / MMSE)
│   ├── demodulator.m             # 심볼 디매핑 + LLR 출력
│   ├── sync/
│   │   ├── freq_sync.m           # 주파수 동기 — FFT Coarse + DD-PLL Fine
│   │   ├── timing_sync.m         # 타이밍 복원 — Gardner TED + 보간
│   │   └── phase_sync.m          # 위상 복원 — Costas Loop (BPSK/QPSK/QAM)
│   └── fec/
│       ├── decoder.m             # FEC 복호기 (LDPC Soft / Turbo MAP / Viterbi)
│       └── deinterleaver.m       # 비트 디인터리버
│
├── simulink/                     # Simulink 모델 빌드 스크립트
│   ├── build_all.m               # 전체 .slx 자동 생성 (이 파일만 실행)
│   ├── build_tx_model.m          # → tx_model.slx
│   ├── build_channel_model.m     # → channel_model.slx
│   ├── build_rx_model.m          # → rx_model.slx
│   └── build_full_chain.m        # → full_chain.slx (TX→Channel→RX 통합)
│
├── utils/
│   ├── ber_calc.m                # BER / SER 계산
│   ├── evm_calc.m                # EVM 측정 (IEEE 802.11 / 3GPP 기준)
│   ├── psd_plot.m                # Welch 방법 PSD 플롯
│   ├── constellation_plot.m      # 성상도 (수신 심볼 + 기준점 비교)
│   └── snr_estimator.m           # SNR 추정 (M2M4 모멘트 기반, 비데이터보조)
│
├── tests/
│   ├── test_modulator.m          # 변조/복조 라운드트립 유닛 테스트
│   ├── test_sync.m               # 주파수·타이밍·위상 동기 유닛 테스트
│   ├── test_channel.m            # 채널 모델 + 링크버짓 유닛 테스트
│   └── test_full_chain.m         # TX→채널→RX 통합 테스트
│
└── results/
    ├── ber_curves/               # BER 결과 (.mat)
    ├── constellations/           # 성상도 이미지
    └── logs/                     # 시뮬레이션 로그
```

---

## 시뮬레이션 체인

```
[Bit Source]
    ↓
[FEC Encoder]  LDPC / Turbo / Conv
    ↓
[Interleaver]
    ↓
[Modulator]    BPSK / QPSK / 16-QAM / 64-QAM  (Gray 부호)
    ↓
[RRC Filter]   Root-Raised Cosine 펄스 성형
    ↓
[RF Impairments]  IQ 불균형 · 위상잡음 · DC 오프셋
    ↓
━━━━━━━━━━━━━━ 채널 ━━━━━━━━━━━━━━
[Multipath]    Rayleigh 페이딩 (ITU VehA/EPA/EVA)
[Doppler]      주파수 편이 (항공 ~5 kHz / LEO 위성 ~20 kHz)
[AWGN]         가우시안 잡음 (Eb/N0 기반)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ↓
[AGC]          전력 정규화
[Freq Sync]    FFT Coarse + DD-PLL Fine
[Timing Sync]  Gardner TED + 보간
[Phase Sync]   Costas Loop
[Ch Estimator] LS / MMSE 파일럿 기반 추정
[Equalizer]    ZF / MMSE
    ↓
[Demodulator]  LLR 출력
[Deinterleaver]
[FEC Decoder]  소프트 결정 복호
    ↓
[BER / EVM 측정]
```

---

## 빠른 시작

### MATLAB 스크립트 시뮬레이션

```matlab
% 1. 경로 설정 및 파라미터 로드
cd wireless_comms_project
addpath(genpath('.'))
run config/sys_params.m
run config/channel_params.m
run config/modem_params.m

% 2. 전체 BER 시뮬레이션 실행
main

% 3. 개별 테스트
cd tests
test_modulator       % 변복조 라운드트립
test_channel         % 채널 모델 + 링크버짓
test_full_chain      % 통합 테스트
```

### Simulink 모델 생성

```matlab
cd wireless_comms_project/simulink
build_all            % tx_model.slx / channel_model.slx / rx_model.slx / full_chain.slx 생성
open('full_chain.slx')
sim('full_chain')
```

> **참고**: Simulink 모델은 MATLAB Function 블록 기반으로 구현되어 Communications Toolbox 블록 없이도 동작합니다.

---

## 주요 파라미터 (config/)

| 파라미터 | 기본값 | 설명 |
|---|---|---|
| `sys.fs` | 10 MHz | 샘플레이트 |
| `sys.fc` | 2.4 GHz | 반송파 주파수 |
| `sys.Rs` | 1 Mbaud | 심볼 레이트 |
| `modem.scheme` | 16-QAM | 변조 방식 |
| `modem.fec_type` | LDPC | FEC 종류 |
| `modem.code_rate` | 1/2 | 부호율 |
| `modem.rolloff` | 0.25 | RRC 롤오프 계수 (α) |
| `ch.doppler_hz` | 5,000 Hz | 최대 도플러 편이 |
| `ch.path_profile` | ITU VehA | 멀티패스 지연 프로파일 |
| `sat.orbit` | LEO | 위성 궤도 종류 |
| `sat.altitude_km` | 550 km | 궤도 고도 |

---

## 표준 참조

| 블록 | 참조 표준 |
|---|---|
| LDPC | DVB-S2 (ETSI EN 302 307) |
| Turbo Code | 3GPP LTE TS 36.212 |
| Viterbi (Conv) | IS-95 / CCSDS |
| Multipath 채널 | ITU-R M.1225 (EPA / EVA / ETU) |
| 위성 링크버짓 | ITU-R S.465 / ETSI EN 301 790 |
| Okumura-Hata | ITU-R P.529 |
| RRC 필터 | IS-95 / 3GPP TS 25.101 |
| Costas Loop | Proakis & Salehi, Digital Communications |
| Gardner TED | F.M. Gardner, "A BPSK/QPSK Timing-Error Detector" |

---

## 요구 사항

- MATLAB R2021a 이상
- Signal Processing Toolbox
- Communications Toolbox (FEC 블록 사용 시)
- Stateflow (Simulink MATLAB Function 블록 편집 시)
