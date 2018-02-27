%% Main Script for Proteins
specific_path = '/home/jhow/Documents/OfficialRents/';
addpath(genpath(specific_path))
net_path = strcat(specific_path, 'DataSets/BIOGRID-ORGANISM-3/PPIs/');
cd(net_path)
list_files = dir('*.csv');

% Loop through all species, and process
for t = 1:length(list_files)
    temp_file = list_files(t).name; 
    % Define paths to files
    network_file = [net_path temp_file];
    gotermfinder_file = ['/home/jhow/Documents/OfficialRents/DataSets/BIOGRID-ORGANISM-3/GoTermFinder_results/list_' lower(temp_file(1:end-8)) '_tab.txt'];
    
    %% Use all GO Terms
    main_process_ppi_allModules(network_file, gotermfinder_file, temp_file)

    %% Use REVIGO cut-offs
    revigo_path = strcat(specific_path, 'DataSets/BIOGRID-ORGANISM-3/Revigo_results/');
    revigo_50_file = [revigo_path lower(temp_file(1:end-8)) '_50.csv'];
    main_process_ppi(network_file, gotermfinder_file, revigo_50_file, temp_file, '50')
    
    revigo_70_file = [revigo_path lower(temp_file(1:end-8)) '_70.csv'];
    main_process_ppi(network_file, gotermfinder_file, revigo_70_file, temp_file, '70')
    
    revigo_90_file = [revigo_path lower(temp_file(1:end-8)) '_90.csv'];
    main_process_ppi(network_file, gotermfinder_file, revigo_90_file, temp_file, '90')
end