%% Main Script for STRING, taken from code for TFs
%% Human
specific_path = '/home/jhow/Documents/OfficialRents/';
addpath(genpath(specific_path))
net_path = strcat(specific_path, 'DataSets/STRING/Final_STRING_Networks/');
cd(net_path)

list_files = dir('*.txt');

% Loop through all species, and process
for t = 1:length(list_files)
    temp_file = list_files(t).name;
    species = strsplit(temp_file, '_');
    species = species{2};
    species = species(1:end-4);
    % Define paths to files
    network_file = [net_path temp_file];
    gotermfinder_file = ['/home/jhow/Documents/OfficialRents/DataSets/STRING/GoTermFinder_results/' temp_file(1:end-4) '_tab.txt'];
    
    %% Use REVIGO cut-offs
    revigo_path = strcat(specific_path, 'DataSets/STRING/Revigo_results/');
    revigo_50_file = [revigo_path species '_50.csv'];
    main_process_STRING(network_file, gotermfinder_file, revigo_50_file, temp_file, '50', species)
    
    revigo_70_file = [revigo_path species '_70.csv'];
    main_process_STRING(network_file, gotermfinder_file, revigo_70_file, temp_file, '70', species)
    
    revigo_90_file = [revigo_path species '_90.csv'];
    main_process_STRING(network_file, gotermfinder_file, revigo_90_file, temp_file, '90', species)
end