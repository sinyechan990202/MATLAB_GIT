% build_all.m — Run this once to generate all .slx files

cd(fileparts(mfilename('fullpath')));

build_tx_model;
build_channel_model;
build_rx_model;
build_full_chain;

fprintf('\nAll Simulink models built successfully.\n');
