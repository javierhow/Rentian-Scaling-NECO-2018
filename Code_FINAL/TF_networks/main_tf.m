%% Main Script for TFs
%% Mouse
specific_path = '/home/jhow/Documents/OfficialRents/';
addpath(genpath(specific_path))
mouse_net_path = strcat(specific_path, 'DataSets/TranscriptionFactors_data/MouseTFs_data/Mouse_Networks');
cd(mouse_net_path)

list_files = dir('*.txt');

% Loop through all species, and process
for t = 1:length(list_files)
    temp_file = list_files(t).name;
    % Define paths to files
    network_file = [mouse_net_path temp_file];
    gotermfinder_file = ['/home/jhow/Documents/OfficialRents/DataSets/TranscriptionFactors_data/MouseTFs_data/GoTermFinder/' temp_file(1:end-4) '_tab.txt'];
    
    %% Use REVIGO cut-offs
    mouse_revigo_path = strcat(specific_path, 'DataSets/TranscriptionFactors_data/MouseTFs_data/Revigo/');
    revigo_50_file = [mouse_revigo_path temp_file(1:end-4) '_revigo_50.csv'];
    main_process_tf(network_file, gotermfinder_file, revigo_50_file, temp_file, '50', 'Mouse')
    
    revigo_70_file = [mouse_revigo_path temp_file(1:end-4) '_revigo_70.csv'];
    main_process_tf(network_file, gotermfinder_file, revigo_70_file, temp_file, '70', 'Mouse')
    
    revigo_90_file = [mouse_revigo_path temp_file(1:end-4) '_revigo_90.csv'];
    main_process_tf(network_file, gotermfinder_file, revigo_90_file, temp_file, '90', 'Mouse')
end

%% Human
human_net_path = strcat(specific_path, 'DataSets/TranscriptionFactors_data/HumanTFs_data/Human_Networks');
cd(human_net_path)

list_files = dir('*.txt');

% Loop through all species, and process
for t = 1:length(list_files)
    temp_file = list_files(t).name;
    % Define paths to files
    network_file = [human_net_path temp_file];
    gotermfinder_file = ['/home/jhow/Documents/OfficialRents/DataSets/TranscriptionFactors_data/HumanTFs_data/GoTermFinder/' temp_file(1:end-4) '_tab.txt'];
    
    human_revigo_path = strcat(specific_path, 'DataSets/TranscriptionFactors_data/HumanTFs_data/Revigo/');
    revigo_50_file = [human_revigo_path temp_file(1:end-4) '_revigo_50.csv'];
    main_process_tf(network_file, gotermfinder_file, revigo_50_file, temp_file, '50', 'Human')
    
    revigo_70_file = [human_revigo_path temp_file(1:end-4) '_revigo_70.csv'];
    main_process_tf(network_file, gotermfinder_file, revigo_70_file, temp_file, '70', 'Human')
    
    revigo_90_file = [human_revigo_path temp_file(1:end-4) '_revigo_90.csv'];
    main_process_tf(network_file, gotermfinder_file, revigo_90_file, temp_file, '90', 'Human')
end