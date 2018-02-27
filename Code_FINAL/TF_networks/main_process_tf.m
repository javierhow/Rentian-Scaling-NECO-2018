function output = main_process_tf(network_name, module_name, revigo_name, temp_file, revigo_cutoff, species)
poolobj = parpool(30);
%% Import network
network = import_tfs_network(network_name);
%% Import modules
modulesgotermfinder = import_modules(module_name);

%% Keep significant GO Terms
significant_go_terms = importfile_revigo(revigo_name);
modulesgotermfinder = keep_revigo(modulesgotermfinder, significant_go_terms);

%% Process
modulesgotermfinder = cellfun(@char, modulesgotermfinder, 'UniformOutput', false);

newNetwork = processNetwork(network, modulesgotermfinder);                  % If not in modules, remove from network
newNetwork = strtrim(newNetwork);
newModules = processModules(newNetwork, modulesgotermfinder);               % If not in network, remove from modules
newModules = strtrim(newModules);
newModules = cellfun(@char, newModules, 'UniformOutput', false);

%% Remove large (i.e. size >= N/2) modules
[newModules, newNetwork] = removeLargeModules(newModules, newNetwork);

%% Calculate Rent's exponents
[Empirical_rent, b2, R2, randomMod_rent, randomEdge_rent, ...
    random_mod_edge_rent, h, p, x, y, randModx, randMody, ...
    randEdgex, randEdgey, randBothx, randBothy] ...
    = processRentExponent_v3(newModules, newNetwork);
delete(poolobj);

numNodes = length(unique(newNetwork(:)));
freeNet = removeRedundantNet(newNetwork);
numEdges = size(freeNet,1);
numModules = size(newModules,1);

save(['/home/jhow/Documents/OfficialRents/Results_v6/TFs/' species '/' temp_file(1:end-4) '_' revigo_cutoff '.mat'])
clear,clc
output = 0;
end