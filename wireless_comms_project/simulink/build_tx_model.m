% build_tx_model.m — Programmatically creates tx_model.slx

mdl = 'tx_model';
if bdIsLoaded(mdl), close_system(mdl, 0); end
new_system(mdl);
open_system(mdl);

%% ---- Blocks ----
add_block('simulink/Sources/Random Number', [mdl '/Bit Source'], ...
    'Mean','0.5','Variance','0.25','SampleTime','1/1e6', ...
    'Position',[30 60 130 100]);

add_block('simulink/User-Defined Functions/MATLAB Function', [mdl '/Modulator'], ...
    'Position',[200 55 320 105]);
set_param([mdl '/Modulator'], 'MATLABFunction', ...
    'function y = fcn(x); y = qammod(round(x),16,''UnitAveragePower'',true);');

add_block('simulink/User-Defined Functions/MATLAB Function', [mdl '/RRC Filter'], ...
    'Position',[380 55 500 105]);
set_param([mdl '/RRC Filter'], 'MATLABFunction', ...
    'function y = fcn(x); persistent h; if isempty(h), h = rcosdesign(0.25,8,4,''sqrt''); end; y = filter(h,1,x);');

add_block('simulink/User-Defined Functions/MATLAB Function', [mdl '/RF Impairments'], ...
    'Position',[560 55 700 105]);
set_param([mdl '/RF Impairments'], 'MATLABFunction', ...
    'function y = fcn(x); amp = 10^(0.5/20); ph = 1*pi/180; I=real(x); Q=imag(x); y = complex(amp*(I*cos(ph/2)-Q*sin(ph/2)), I*sin(ph/2)+Q*cos(ph/2));');

add_block('simulink/Sinks/Out1', [mdl '/TX Out'], ...
    'Position',[790 70 820 90]);

%% ---- Connections ----
add_line(mdl, 'Bit Source/1',    'Modulator/1');
add_line(mdl, 'Modulator/1',     'RRC Filter/1');
add_line(mdl, 'RRC Filter/1',    'RF Impairments/1');
add_line(mdl, 'RF Impairments/1','TX Out/1');

set_param(mdl, 'SolverType','Fixed-step','Solver','FixedStepDiscrete', ...
    'FixedStep','1/10e6','StopTime','1e-3');

save_system(mdl, fullfile(fileparts(mfilename('fullpath')), 'tx_model.slx'));
fprintf('Saved: tx_model.slx\n');
