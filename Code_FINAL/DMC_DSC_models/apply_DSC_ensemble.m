function rent_exponents_logfit = apply_DSC_ensemble(newNetwork, newModules, file_name, Empirical_rent, num_iterations)
%% Forward DSC model to achieve a specific Rent's exponent
poolobj = parpool(32);
%% Initialize variables
range = (0.1:0.1:0.9);
qmod = range;
qcon = range;
pfav = range;

%% Make nodesCombined
nodesCombined = makeNodesCombined(newModules);
%% Make list of modules for each node
mods_per_all_nodes = listModulesperNode_all_java(nodesCombined, newModules, newNetwork);
%% Produce many iterations
uniqueNodes = unique(newNetwork(:));
rent_exponents_logfit = nan(length(qmod), length(qcon), length(pfav), num_iterations);
b2_logfit = nan(length(qmod), length(qcon), length(pfav), num_iterations);
mse_logfit = nan(length(qmod), length(qcon), length(pfav), num_iterations);
R2_logfit = nan(length(qmod), length(qcon), length(pfav), num_iterations);
network_size = nan(length(qmod), length(qcon), length(pfav), num_iterations);
numberUniqueNodes = nan(length(qmod), length(qcon), length(pfav), num_iterations);
n = length(qmod);

un = parallel.pool.Constant(uniqueNodes);
nm = parallel.pool.Constant(newModules);
mpan = parallel.pool.Constant(mods_per_all_nodes);


parfor g = 1:num_iterations
    n_s = nan(length(qmod), length(qcon), length(pfav));
    nUN = nan(length(qmod), length(qcon), length(pfav));
    r_e_l = nan(length(qmod), length(qcon), length(pfav));
    b_l = nan(length(qmod), length(qcon), length(pfav));
    m_l = nan(length(qmod), length(qcon), length(pfav));
    R_l = nan(length(qmod), length(qcon), length(pfav));
    for t = 1:n
            temp_pfav = pfav(t);
            for v = 1:n
                temp_qcon = qcon(v);
                for b = 1:n
                    temp_qmod = qmod(b);
                    
                    sC = forward_DSC(un.Value, nm.Value, mpan.Value, ...
                        temp_qmod, temp_qcon, temp_pfav);

                    temp_network = fast_sC_to_network(sC);
                    
                    n_s(b,v,t) = length(temp_network);
                    nUN(b,v,t) = length(unique(temp_network(:)));
                    
                    [r_e_l(b,v,t), b_l(b,v,t), m_l(b,v,t), R_l(b,v,t)] = get_RentExponent_logfit(nm.Value, sC);
                end   
            end
    end
    network_size(:,:,:,g) = n_s;
    numberUniqueNodes(:,:,:,g) = nUN;
    rent_exponents_logfit(:,:,:,g) = r_e_l;
    b2_logfit(:,:,:,g) = b_l;
    mse_logfit(:,:,:,g) = m_l;
    R2_logfit(:,:,:,g) = R_l;
end

if exist('poolobj','var')
    delete(poolobj)
else
    delete(gcp)
end

temp_net = removeRedundantNet(newNetwork);
size_empiricalNetwork = length(temp_net);

clear newNetwork newModules nodesCombined mods_per_all_nodes sC temp_network
save(['/home/jhow/Documents/OfficialRents/Results_v6/DSC/' file_name '_forwardDSCEnsemble_final.mat'])
end