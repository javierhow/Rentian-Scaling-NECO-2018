function output = main_process_ppi_allModules(network_name, module_name, temp_file)
%% Import network
network = import_ppi_network(network_name);
%% Import modules
modulesgotermfinder = import_modules(module_name);
%% Process
modulesgotermfinder = cellfun(@char, modulesgotermfinder, 'UniformOutput', false);

newNetwork = processNetwork(network, modulesgotermfinder);                  % if not in modules, remove from network
newNetwork = strtrim(newNetwork);
newModules = processModules(newNetwork, modulesgotermfinder);               % if not in network, remove from modules
newModules = strtrim(newModules);
newModules = cellfun(@char, newModules, 'UniformOutput', false);

%% Remove large (i.e. size >= N/2) modules
[newModules, newNetwork] = removeLargeModules(newModules, newNetwork);

%% Clear the workspace
clearvars -except newModules newNetwork temp_file

%% Calculate Rent's exponent
[Empirical_rent, b2, R2, randomMod_rent, randomEdge_rent, ...
    random_mod_edge_rent, h, p, x, y, av_x, av_y, randModx, randMody, ...
    randEdgex, randEdgey, randBothx, randBothy] ...
    = processRentExponent_v3_gotermfinder(newModules, newNetwork);

numNodes = length(unique(newNetwork(:)));
freeNet = removeRedundantNet(newNetwork);
numEdges = size(freeNet,1);
numModules = size(newModules,1);

save(['/home/jhow/Documents/OfficialRents/Results_v6/PPI/' temp_file(1:end-8) '_allGoTerms.mat'])
output = 0;
end