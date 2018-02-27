function rent_exponents_logfit = apply_DSC_ensemble_parameters(newNetwork, newModules, file_name, Empirical_rent, num_iterations, parameters)
%% Forward DSC model to achieve a specific Rent's exponent, given param.s
poolobj = parpool(16);
%% Initialize variables
qmod = parameters(1);
qcon = parameters(2);
pfav = parameters(3);

%% Make nodesCombined
nodesCombined = makeNodesCombined(newModules);
%% Make list of modules for each node
mods_per_all_nodes = listModulesperNode_all_java(nodesCombined, newModules, newNetwork);
%% Use code
uniqueNodes = unique(newNetwork(:));
rent_exponents_logfit = nan(num_iterations, 1);
b2_logfit = nan(num_iterations, 1);
mse_logfit = nan(num_iterations, 1);
R2_logfit = nan(num_iterations, 1);
network_size = nan(num_iterations, 1);
numberUniqueNodes = nan(num_iterations, 1);
n = length(qmod);
x_all = cell(num_iterations, 1);
y_all = cell(num_iterations, 1);

parfor g = 1:num_iterations
    sC = forward_DSC(uniqueNodes, newModules, mods_per_all_nodes, qmod, ...
        qcon, pfav);
    temp_network = fast_sC_to_network(sC);
    network_size(g) = length(temp_network);
    numberUniqueNodes(g) = length(unique(temp_network(:)));
    [rent_exponents_logfit(g), b2_logfit(g), mse_logfit(g), R2_logfit(g), x_all{g}, y_all{g}] = get_RentExponent_logfit(newModules, sC);
end

if exist('poolobj','var')
    delete(poolobj)
else
    delete(gcp)
end

temp_net = removeRedundantNet(newNetwork);
size_empiricalNetwork = length(temp_net);

clear newNetwork newModules nodesCombined mods_per_all_nodes sC temp_network
save(['/home/jhow/Documents/OfficialRents/Results_v6/DSC/' file_name '_forwardDSCEnsemble_final_qmod_' num2str(qmod) '_qcon_' num2str(qcon) '_pfav_' num2str(pfav) '.mat'])
end