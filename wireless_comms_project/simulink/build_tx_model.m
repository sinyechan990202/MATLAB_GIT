% build_tx_model.m — Programmatically creates tx_model.slx

mdl = 'tx_model';
if bdIsLoaded(mdl), close_system(mdl, 0); end
new_system(mdl);
open_system(mdl);

lib = 'simulink/User-Defined Functions/MATLAB Function';
px  = 30; step = 180;

%% Bit Source
add_block('simulink/Sources/Random Number', [mdl '/Bit Source'], ...
    'Mean','0.5','Variance','0.25','SampleTime','1/1e6', ...
    'Position',[px 60 px+110 100]);
px = px + step;

%% Modulator
add_block(lib, [mdl '/Modulator'], 'Position',[px 55 px+130 105]);
set_fcn(mdl, 'Modulator', ...
    ['function y = fcn(x)' newline ...
     'y = qammod(round(x), 16, ''UnitAveragePower'', true);']);
px = px + step;

%% RRC Filter
add_block(lib, [mdl '/RRC Filter'], 'Position',[px 55 px+130 105]);
set_fcn(mdl, 'RRC Filter', ...
    ['function y = fcn(x)' newline ...
     'persistent h' newline ...
     'if isempty(h), h = rcosdesign(0.25, 8, 4, ''sqrt''); end' newline ...
     'y = filter(h, 1, x);']);
px = px + step;

%% RF Impairments
add_block(lib, [mdl '/RF Impairments'], 'Position',[px 55 px+130 105]);
set_fcn(mdl, 'RF Impairments', ...
    ['function y = fcn(x)' newline ...
     'amp = 10^(0.5/20); ph = 1*pi/180;' newline ...
     'I = real(x); Q = imag(x);' newline ...
     'y = complex(amp*(I*cos(ph/2) - Q*sin(ph/2)), I*sin(ph/2) + Q*cos(ph/2));']);
px = px + step;

%% Output
add_block('simulink/Sinks/Out1', [mdl '/TX Out'], 'Position',[px 70 px+30 90]);

%% Connections
add_line(mdl, 'Bit Source/1',    'Modulator/1');
add_line(mdl, 'Modulator/1',     'RRC Filter/1');
add_line(mdl, 'RRC Filter/1',    'RF Impairments/1');
add_line(mdl, 'RF Impairments/1','TX Out/1');

set_param(mdl, 'SolverType','Fixed-step','Solver','FixedStepDiscrete', ...
    'FixedStep','1/10e6','StopTime','1e-3');

save_system(mdl, fullfile(fileparts(mfilename('fullpath')), 'tx_model.slx'));
fprintf('Saved: tx_model.slx\n');

%% Helper — set MATLAB Function block script via Stateflow API
function set_fcn(mdl, blk_name, script)
    rt  = sfroot();
    ch  = rt.find('-isa','Stateflow.EMChart','Path',[mdl '/' blk_name]);
    ch.Script = script;
end
