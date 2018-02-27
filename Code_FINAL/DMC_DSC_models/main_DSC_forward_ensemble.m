%% Forward DSC model
specific_path = '/home/jhow/Documents/OfficialRents/';
addpath(genpath(specific_path))
cd('/home/jhow/Documents/OfficialRents/Results_v6/PPI')

% DSC takes longer than DMC, so start with 32, then manually feed the best 
% parameters to main_DSC_forward_ensemble_parameters.m
num_iterations = 32;
entire_list = {'*50.mat', '*70.mat', '*90.mat'};
rng(4, 'combRecursive')

%% Loop through all species and REVIGO cut-offs, and process
for k = 1:length(entire_list)
    list_files = dir(entire_list{k});
    for t = 1:length(list_files)
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
        
        if num_iterations > 1
            apply_DSC_ensemble(newNetwork, newModules, file_name, Empirical_rent, num_iterations)
        else
            apply_DSC_once(newNetwork, newModules, file_name, Empirical_rent, num_iterations)
        end
        
        clearvars -except t list_files num_revigo_cutoffs ...
            num_iterations entire_list k
    end
end