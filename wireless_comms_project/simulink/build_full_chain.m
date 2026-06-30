% build_full_chain.m — Builds full_chain.slx integrating TX/Channel/RX as subsystems

mdl     = 'full_chain';
sim_dir = fileparts(mfilename('fullpath'));

if bdIsLoaded(mdl), close_system(mdl, 0); end
new_system(mdl);
open_system(mdl);

lib = 'simulink/User-Defined Functions/MATLAB Function';

%% Sub-models (Model Reference blocks)
add_block('simulink/Ports & Subsystems/Model', [mdl '/TX Model'], ...
    'ModelName','tx_model','Position',[60 80 200 140]);

add_block('simulink/Ports & Subsystems/Model', [mdl '/Channel Model'], ...
    'ModelName','channel_model','Position',[270 80 410 140]);

add_block('simulink/Ports & Subsystems/Model', [mdl '/RX Model'], ...
    'ModelName','rx_model','Position',[480 80 620 140]);

%% BER Calculator (MATLAB Function — no toolbox dependency)
add_block(lib, [mdl '/BER Calc'], 'Position',[700 75 860 145]);
set_fcn(mdl, 'BER Calc', ...
    ['function [ber, n_err] = fcn(rx_bits, tx_bits)' newline ...
     'n      = min(length(rx_bits), length(tx_bits));' newline ...
     'n_err  = sum(rx_bits(1:n) ~= tx_bits(1:n));' newline ...
     'ber    = n_err / n;']);

%% Display
add_block('simulink/Sinks/Display', [mdl '/BER Display'], ...
    'Position',[920 90 1040 130]);

%% TX bits reference (from TX model — loopback via workspace or inport)
add_block('simulink/Sources/In1', [mdl '/Ref Bits'], ...
    'Position',[700 175 730 195]);

%% Connections
add_line(mdl, 'TX Model/1',     'Channel Model/1');
add_line(mdl, 'Channel Model/1','RX Model/1');
add_line(mdl, 'RX Model/1',     'BER Calc/1');
add_line(mdl, 'Ref Bits/1',     'BER Calc/2');
add_line(mdl, 'BER Calc/1',     'BER Display/1');

set_param(mdl, 'SolverType','Fixed-step','Solver','FixedStepDiscrete', ...
    'FixedStep','1/10e6','StopTime','10e-3');

save_system(mdl, fullfile(sim_dir, 'full_chain.slx'));
fprintf('Saved: full_chain.slx\n');

function set_fcn(mdl, blk_name, script)
    rt = sfroot();
    ch = rt.find('-isa','Stateflow.EMChart','Path',[mdl '/' blk_name]);
    ch.Script = script;
end
