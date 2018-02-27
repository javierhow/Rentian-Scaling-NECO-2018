function output = main_process_socialNets(network_name, module_name, temp_file)
%% Import network
network = import_social_network(network_name);
%% Import modules
modules = import_social_comms(module_name);
%% Process
modules = cellfun(@char, modules, 'UniformOutput', false);

newNetwork = processNetwork(network, modules);                              % If not in modules, remove from network
newNetwork = strtrim(newNetwork);
newModules = processModules(newNetwork, modules);                           % If not in network, remove from modules
newModules = strtrim(newModules);
newModules = cellfun(@char, newModules, 'UniformOutput', false);

%% Remove large (i.e. size >= N/2) modules
[newModules, newNetwork] = removeLargeModules(newModules, newNetwork);

%% Calculate Rent's exponents, w/o associatied randomizations
%[Empirical_rent, randomMod_rent, randomEdge_rent, randomModSingle_Rent, h, p] = processRentExponent(newModules, newNetwork);
[Empirical_rent, b2, R2, x, y] ...
    = processRentExponent_v3_no_randomize(newModules, newNetwork);

[av_x, av_y] = average_modules(x,y);
[averagedEmpirical_rent, averagedb2, averagedMSE, averagedR2] ...
    = logfit(av_x, av_y, 'loglog');

numNodes = length(unique(newNetwork(:)));
freeNet = removeRedundantNet(newNetwork);
numEdges = size(freeNet,1);
numModules = size(newModules,1);

clear modules newModules

save(['/home/jhow/Documents/OfficialRents/Results_v6/Social/' temp_file '-results.mat'])
clear,clc
output = 0;
end