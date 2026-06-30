% build_full_chain.m — full_chain.slx
% TX Model → Channel Model → RX Model 을 Model Reference로 연결
% 256x1 복소 벡터 신호 기준

mdl     = 'full_chain';
sim_dir = fileparts(mfilename('fullpath'));

if bdIsLoaded(mdl), close_system(mdl, 0); end
new_system(mdl);
open_system(mdl);

lib = 'simulink/User-Defined Functions/MATLAB Function';

%% Signal Specification helper: 두 Model Reference 사이 신호 차원 명시
function add_sigspec(mdl, name, px, py)
    add_block('simulink/Signal Attributes/Signal Specification', ...
        [mdl '/' name], ...
        'Dimensions','256', 'Complexity','complex', ...
        'Position',[px py px+60 py+30]);
end

%% Sub-models (Model Reference)
add_block('simulink/Ports & Subsystems/Model', [mdl '/TX Model'], ...
    'ModelName','tx_model','Position',[60 80 200 130]);

add_sigspec(mdl, 'Sig1', 230, 95);

add_block('simulink/Ports & Subsystems/Model', [mdl '/Channel Model'], ...
    'ModelName','channel_model','Position',[320 80 460 130]);

add_sigspec(mdl, 'Sig2', 490, 95);

add_block('simulink/Ports & Subsystems/Model', [mdl '/RX Model'], ...
    'ModelName','rx_model','Position',[580 80 720 130]);

%% EVM Measurement (MATLAB Function)
add_block(lib, [mdl '/EVM Calc'], 'Position',[790 75 940 135]);
set_fcn(mdl, 'EVM Calc', ...
    ['function evm = fcn(rx_sym)' newline ...
     '% EVM vs ideal 16-QAM constellation' newline ...
     'rx_d   = qamdemod(rx_sym, 16, ''UnitAveragePower'', true);' newline ...
     'tx_ref = qammod(rx_d,    16, ''UnitAveragePower'', true);' newline ...
     'err    = rx_sym - tx_ref;' newline ...
     'evm    = sqrt(mean(abs(err).^2) / mean(abs(tx_ref).^2)) * 100;']);

add_block('simulink/Sinks/Display', [mdl '/EVM Display'], ...
    'Position',[1000 90 1120 120]);

%% Connections
add_line(mdl, 'TX Model/1',      'Sig1/1');
add_line(mdl, 'Sig1/1',          'Channel Model/1');
add_line(mdl, 'Channel Model/1', 'Sig2/1');
add_line(mdl, 'Sig2/1',          'RX Model/1');
add_line(mdl, 'RX Model/1',      'EVM Calc/1');
add_line(mdl, 'EVM Calc/1',      'EVM Display/1');

set_param(mdl, 'SolverType','Fixed-step','Solver','FixedStepDiscrete', ...
    'FixedStep','1','StopTime','100');

save_system(mdl, fullfile(sim_dir, 'full_chain.slx'));
fprintf('Saved: full_chain.slx\n');

%% Helpers
function set_fcn(mdl, blk_name, script)
    rt = sfroot();
    ch = rt.find('-isa','Stateflow.EMChart','Path',[mdl '/' blk_name]);
    ch.Script = script;
end
