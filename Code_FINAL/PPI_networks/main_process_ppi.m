function output = main_process_ppi(network_name, module_name, revigo_name, temp_file, revigo_cutoff, species)
%% Start parallel pool
poolSize = 30;
poolobj = parpool(poolSize);
%% Import network
network = import_ppi_network(network_name);
%% Import modules
modulesgotermfinder = import_modules(module_name);
%% Keep significant GO Terms
significant_go_terms = importfile_revigo(revigo_name);
significant_go_terms = upper(significant_go_terms);
modulesgotermfinder = keep_revigo(modulesgotermfinder, significant_go_terms);

%% Process
modulesgotermfinder = cellfun(@char, modulesgotermfinder, 'UniformOutput', false);

newNetwork = processNetwork(network, modulesgotermfinder);                  % if not in modules, remove from network
newNetwork = strtrim(newNetwork);
newModules = processModules(newNetwork, modulesgotermfinder);               % if not in network, remove from modules; pointless to do this first
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

save(['/home/jhow/Documents/OfficialRents/Results_v6/PPI/' temp_file(1:end-8) '_' revigo_cutoff '.mat'])
clear,clc
output = 0;
end