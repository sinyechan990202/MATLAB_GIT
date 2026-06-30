% build_full_chain.m  [클럭 단위]
% TX → Channel → RX 통합 모델
% 신호: 스칼라 복소수, 클럭 = 1/10MHz

mdl     = 'full_chain';
sim_dir = fileparts(mfilename('fullpath'));

if bdIsLoaded(mdl), close_system(mdl, 0); end
new_system(mdl);
open_system(mdl);

lib = 'simulink/User-Defined Functions/MATLAB Function';

%% ── Sub-models (Model Reference) ─────────────────────────────────────────────
add_block('simulink/Ports & Subsystems/Model', [mdl '/TX Model'], ...
    'ModelName','tx_model','Position',[60 90 200 140]);

add_block('simulink/Ports & Subsystems/Model', [mdl '/Channel Model'], ...
    'ModelName','channel_model','Position',[280 90 420 140]);

add_block('simulink/Ports & Subsystems/Model', [mdl '/RX Model'], ...
    'ModelName','rx_model','Position',[500 80 640 150]);

%% ── Signal Specification (스칼라 복소 명시) ──────────────────────────────────
add_block('simulink/Signal Attributes/Signal Specification', [mdl '/Spec1'], ...
    'Dimensions','1', 'Position',[230 103 260 127]);

add_block('simulink/Signal Attributes/Signal Specification', [mdl '/Spec2'], ...
    'Dimensions','1', 'Position',[450 103 480 127]);

%% ── EVM 모니터 (MATLAB Function) ─────────────────────────────────────────────
add_block(lib, [mdl '/EVM Monitor'], 'Position',[720 85 880 145]);
set_fcn(mdl, 'EVM Monitor', ...
    ['function evm_db = fcn(sym, valid)' newline ...
     '% 복소 심볼 EVM 추정 — valid=1인 샘플만 사용' newline ...
     'persistent err_acc ref_acc n' newline ...
     'if isempty(n), err_acc=double(0); ref_acc=double(1e-10); n=int32(0); end' newline ...
     'evm_db = double(-30);' newline ...
     'if valid > 0.5' newline ...
     '    rx_d   = qamdemod(sym, 16, ''UnitAveragePower'', true);' newline ...
     '    ref    = qammod(rx_d, 16, ''UnitAveragePower'', true);' newline ...
     '    err_acc = err_acc + real((sym-ref)*conj(sym-ref));' newline ...
     '    ref_acc = ref_acc + real(ref*conj(ref));' newline ...
     '    n = n + int32(1);' newline ...
     '    if n >= int32(100)' newline ...
     '        evm_db = 10*log10(err_acc / ref_acc);' newline ...
     '    end' newline ...
     'end']);

%% ── Scope / Display ───────────────────────────────────────────────────────────
add_block('simulink/Sinks/Display', [mdl '/EVM (dB)'], ...
    'Position',[940 100 1060 130]);

add_block('simulink/Sinks/Scope', [mdl '/Scope TX'], ...
    'Position',[230 170 280 210]);

add_block('simulink/Sinks/Scope', [mdl '/Scope RX'], ...
    'Position',[660 170 710 210]);

%% ── 연결 ─────────────────────────────────────────────────────────────────────
add_line(mdl, 'TX Model/1',      'Spec1/1');
add_line(mdl, 'Spec1/1',         'Channel Model/1');
add_line(mdl, 'Spec1/1',         'Scope TX/1');
add_line(mdl, 'Channel Model/1', 'Spec2/1');
add_line(mdl, 'Spec2/1',         'RX Model/1');
add_line(mdl, 'RX Model/1',      'EVM Monitor/1');   % EQ 심볼
add_line(mdl, 'RX Model/2',      'EVM Monitor/2');   % valid
add_line(mdl, 'RX Model/1',      'Scope RX/1');
add_line(mdl, 'EVM Monitor/1',   'EVM (dB)/1');

set_param(mdl, 'SolverType','Fixed-step','Solver','FixedStepDiscrete', ...
    'FixedStep','1/10e6','StopTime','1e-3');

save_system(mdl, fullfile(sim_dir, 'full_chain.slx'));
fprintf('Saved: full_chain.slx\n');

function set_fcn(mdl, blk, script)
    rt = sfroot();
    ch = rt.find('-isa','Stateflow.EMChart','Path',[mdl '/' blk]);
    ch.Script = script;
end
