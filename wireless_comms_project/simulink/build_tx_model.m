% build_tx_model.m
% TX: 복소 QAM 심볼 생성 → RRC 필터 → RF 불균형
% 모든 블록 입출력 크기 = FRAME_LEN (고정)

mdl = 'tx_model';
if bdIsLoaded(mdl), close_system(mdl, 0); end
new_system(mdl);
open_system(mdl);

lib   = 'simulink/User-Defined Functions/MATLAB Function';
FLEN  = 256;   % 심볼 프레임 크기 (고정)
px    = 30; step = 210;

%% QAM Symbol Source (16-QAM, frame = FLEN symbols)
add_block(lib, [mdl '/QAM Source'], 'Position',[px 55 px+140 105]);
set_fcn(mdl, 'QAM Source', ...
    ['function y = fcn(dummy)' newline ...
     'FLEN = 256;' newline ...
     'bits = randi([0 1], FLEN*4, 1);' newline ...
     'y    = qammod(bits, 16, ''InputType'', ''bit'', ''UnitAveragePower'', true);']);
set_complex_output(mdl, 'QAM Source');
px = px + step;

%% RRC Pulse Shaping  (output same size — apply filter, keep FLEN samples)
add_block(lib, [mdl '/RRC Filter'], 'Position',[px 55 px+140 105]);
set_fcn(mdl, 'RRC Filter', ...
    ['function y = fcn(x)' newline ...
     'persistent h' newline ...
     'if isempty(h)' newline ...
     '    h = rcosdesign(0.25, 8, 1, ''sqrt'');' newline ...
     'end' newline ...
     'y = filter(h, 1, x);']);
set_complex_output(mdl, 'RRC Filter');
px = px + step;

%% RF Impairments (IQ imbalance — same size)
add_block(lib, [mdl '/RF Impairments'], 'Position',[px 55 px+140 105]);
set_fcn(mdl, 'RF Impairments', ...
    ['function y = fcn(x)' newline ...
     'amp = 10^(0.5/20);' newline ...
     'ph  = 1 * pi / 180;' newline ...
     'I   = real(x); Q = imag(x);' newline ...
     'y   = complex(amp*(I*cos(ph/2) - Q*sin(ph/2)), ...' newline ...
     '              I*sin(ph/2) + Q*cos(ph/2));']);
set_complex_output(mdl, 'RF Impairments');
px = px + step;

%% Output  (명시적 차원: 256x1 복소 벡터)
add_block('simulink/Sinks/Out1', [mdl '/TX Out'], ...
    'Position',[px 70 px+30 90], ...
    'PortDimensions','256', 'SignalType','complex');

%% Dummy constant input for QAM Source (no data input needed)
add_block('simulink/Sources/Constant', [mdl '/Trigger'], ...
    'Value','0', 'SampleTime','1', 'Position',[30 155 100 185]);

%% Connections
add_line(mdl, 'Trigger/1',      'QAM Source/1');
add_line(mdl, 'QAM Source/1',   'RRC Filter/1');
add_line(mdl, 'RRC Filter/1',   'RF Impairments/1');
add_line(mdl, 'RF Impairments/1','TX Out/1');

set_param(mdl, 'SolverType','Fixed-step','Solver','FixedStepDiscrete', ...
    'FixedStep','1','StopTime','100');

save_system(mdl, fullfile(fileparts(mfilename('fullpath')), 'tx_model.slx'));
fprintf('Saved: tx_model.slx\n');

%% Helpers
function set_fcn(mdl, blk_name, script)
    rt = sfroot();
    ch = rt.find('-isa','Stateflow.EMChart','Path',[mdl '/' blk_name]);
    ch.Script = script;
end

function set_complex_output(mdl, blk_name)
    rt = sfroot();
    ch = rt.find('-isa','Stateflow.EMChart','Path',[mdl '/' blk_name]);
    y  = ch.find('-isa','Stateflow.Data','Name','y');
    if ~isempty(y), y.Complexity = 'On'; end
end
