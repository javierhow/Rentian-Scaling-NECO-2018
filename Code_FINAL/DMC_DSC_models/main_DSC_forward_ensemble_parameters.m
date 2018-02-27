%% Forward DSC model with parameters
specific_path = '/home/jhow/Documents/OfficialRents/';
addpath(genpath(specific_path))
cd('/home/jhow/Documents/OfficialRents/Results_v6/PPI')

% Best parameters for Revigo of 70
param_fly = [0.5, 0.9, 0.9];
param_mouse = [0.7, 0.6, 0.1];
param_plant = [0.6, 0.9, 0.9];
param_spombe = [0.5, 0.8, 0.9];
param_yeast = [0.2, 0.9, 0.9];
% We skip Human
parameters = {param_fly, [], param_mouse, param_plant, param_spombe, param_yeast};

num_iterations = 100;
entire_list = {'*70.mat'};

%% Loop through all species and REVIGO cut-offs, and process
for k = 1:length(entire_list)
    list_files = dir(entire_list{k});
    for t = [1,3:6]                                                         % Skip Human
        temp_file = list_files(t).name;

        % Sometime newModules is too large to save, so we may reproduce it
        file_name = temp_file(1:end-4);
        load(temp_file)
        if ~exist('newModules', 'var')
            species = lower(fileName(1:end-3));
            modules_file_name = ['/home/jhow/Documents/OfficialRents/DataSets/BIOGRID-ORGANISM-3/GoTermFinder_results/list_' species '_tab.txt'];
            revigo_file_name = ['/home/jhow/Documents/OfficialRents/DataSets/BIOGRID-ORGANISM-3/Revigo_results/' lower(file_name) '_.csv'];
            [newModules, newNetwork] = getModules(file_name, ...
                species, modules_file_name, revigo_file_name, newNetwork);
        end
        clearvars -except list_files t temp_file file_name newModules ...
            newNetwork Empirical_rent num_revigo_cutoffs ...
            num_iterations entire_list k

        apply_DSC_ensemble_parameters(newNetwork, newModules, file_name, Empirical_rent, num_iterations, parameters{t})
        clearvars -except t list_files num_revigo_cutoffs ...
            num_iterations entire_list k parameters
    end
end