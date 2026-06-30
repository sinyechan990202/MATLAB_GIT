% build_tx_model.m — Programmatically creates tx_model.slx

mdl = 'tx_model';
if bdIsLoaded(mdl), close_system(mdl, 0); end
new_system(mdl);
open_system(mdl);

%% ---- Blocks ----
add_block('built-in/RandomNumber',      [mdl '/Bit Source'], ...
    'Mean','0.5','Variance','0.25','SampleTime','1/1e6','Position',[30 60 120 100]);

add_block('simulink/Signal Routing/Mux',[mdl '/FEC Encoder Stub'], ...
    'Inputs','1','Position',[180 60 240 100]);

add_block('built-in/MATLAB Function',   [mdl '/Modulator'], ...
    'Position',[320 55 430 105]);
set_param([mdl '/Modulator'], 'MATLABFunction', ...
    'function y = fcn(x); y = qammod(x,16,"UnitAveragePower",true);');

add_block('built-in/MATLAB Function',   [mdl '/RRC Filter'], ...
    'Position',[490 55 600 105]);
set_param([mdl '/RRC Filter'], 'MATLABFunction', ...
    'function y = fcn(x); persistent h; if isempty(h), h=rcosdesign(0.25,8,4,"sqrt"); end; y=filter(h,1,x);');

add_block('built-in/MATLAB Function',   [mdl '/RF Impairments'], ...
    'Position',[660 55 780 105]);
set_param([mdl '/RF Impairments'], 'MATLABFunction', ...
    'function y = fcn(x); y = x * 10^(0.5/20) .* exp(1j*cumsum(1e-4*randn(size(x))));');

add_block('built-in/Outport',           [mdl '/TX Out'], ...
    'Position',[860 70 890 90]);

%% ---- Connections ----
add_line(mdl, 'Bit Source/1',      'FEC Encoder Stub/1');
add_line(mdl, 'FEC Encoder Stub/1','Modulator/1');
add_line(mdl, 'Modulator/1',       'RRC Filter/1');
add_line(mdl, 'RRC Filter/1',      'RF Impairments/1');
add_line(mdl, 'RF Impairments/1',  'TX Out/1');

%% ---- Annotations ----
add_block('built-in/Note', [mdl '/Note1'], ...
    'Position',[30 20 500 45]);
set_param([mdl '/Note1'], 'Text', ...
    'TX Chain: Bit Source → FEC → Modulator (16QAM) → RRC Filter → RF Impairments');

set_param(mdl, 'SolverType','Fixed-step', 'Solver','FixedStepDiscrete', ...
    'FixedStep','1/10e6', 'StopTime','1e-3');

save_system(mdl, fullfile(fileparts(mfilename('fullpath')), 'tx_model.slx'));
fprintf('Saved: tx_model.slx\n');
