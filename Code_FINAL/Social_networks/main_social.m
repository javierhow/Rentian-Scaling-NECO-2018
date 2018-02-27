%% Main Script for Proteins, from TFs
specific_path = '/home/jhow/Documents/OfficialRents/';
addpath(genpath(specific_path))
social_path = strcat(specific_path, 'DataSets/Social_Data');
cd(social_path)

list_net_files = dir('*ungraph.txt');
list_community_files = dir('*cmty.txt');
% Loop through all species, and process
for t = 1:length(list_net_files)
    temp_file = list_net_files(t).name;
    % Define paths to files
    network_file = [social_path temp_file];
    communities_file = [social_path temp_file(1:end-11) ...
        'top5000.cmty.txt'];                                                % Use top 5000 communities
    
    main_process_socialNets(network_file, communities_file, temp_file(1:end-11))
end