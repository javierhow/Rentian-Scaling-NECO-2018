function rent_exponents_logfit = apply_DMC_raw_ensemble(newNetwork, newModules, file_name, Empirical_rent, num_iterations)
%% Forward DMC model, to achieve a specific Rent's exponent
poolobj = parpool(32);
%% Initialize variables
range = (0.1:0.1:0.9);
qmod = range;
qcon = range;

%% Make nodesCombined
nodesCombined = makeNodesCombined(newModules);
%% Make list of modules for each node
mods_per_all_nodes = listModulesperNode_all_java(nodesCombined, newModules, newNetwork);
%% Produce many iterations
uniqueNodes = unique(newNetwork(:));
rent_exponents_logfit = nan(length(qmod), length(qcon), num_iterations);
R2_logfit = nan(length(qmod), length(qcon), num_iterations);
b2_logfit = nan(length(qmod), length(qcon), num_iterations);
mse_logfit = nan(length(qmod), length(qcon), num_iterations);
network_size = nan(length(qmod), length(qcon), num_iterations);
numberUniqueNodes = nan(length(qmod), length(qcon), num_iterations);
n = length(qmod);

parfor g = 1:num_iterations 
    n_s = nan(length(qmod), length(qcon));
    nUN = nan(length(qmod), length(qcon));
    r_e_l = nan(length(qmod), length(qcon));
    b_l = nan(length(qmod), length(qcon));
    m_l = nan(length(qmod), length(qcon));
    R_l = nan(length(qmod), length(qcon));
    for v = 1:n
        temp_qcon = qcon(v);
        for b = 1:n
            temp_qmod = qmod(b);
            sC = forward_raw_DMC(uniqueNodes, newModules, mods_per_all_nodes, ...
                temp_qmod, temp_qcon);
            temp_network = fast_sC_to_network(sC);
            n_s(b,v) = length(temp_network);
            nUN(b,v) = length(unique(temp_network(:)));
            [r_e_l(b,v), b_l(b,v), m_l(b,v), R_l(b,v)] = get_RentExponent_logfit(newModules, sC);            
        end
    end    
    network_size(:,:,g) = n_s;
    numberUniqueNodes(:,:,g) = nUN;
    rent_exponents_logfit(:,:,g) = r_e_l;
    b2_logfit(:,:,g) = b_l;
    mse_logfit(:,:,g) = m_l;
    R2_logfit(:,:,g) = R_l;
end


if exist('poolobj','var')
    delete(poolobj)
else
    delete(gcp)
end

temp_net = removeRedundantNet(newNetwork);
size_empiricalNetwork = length(temp_net);

clear newNetwork newModules nodesCombined mods_per_all_nodes sC temp_network

save(['/home/jhow/Documents/OfficialRents/Results_v6/DMC_raw/' file_name '_forwardRawDMCEnsemble_final.mat'])
end