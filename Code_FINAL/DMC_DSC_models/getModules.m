function [newModules, newNetwork] = getModules(fileName, species, modules_file_name, revigo_file_name, newNetwork)
%% Import modules
modulesgotermfinder = import_modules(modules_file_name);

%% Keep significant GO Terms
significant_go_terms = importfile_revigo(revigo_file_name);
significant_go_terms = upper(significant_go_terms);
modulesgotermfinder = keep_revigo(modulesgotermfinder, significant_go_terms);

%% Process
modulesgotermfinder = cellfun(@char, modulesgotermfinder, 'UniformOutput', false);
% newNetwork is just fine
newModules = processModules(newNetwork, modulesgotermfinder);               % If not in network, remove from modules
newModules = strtrim(newModules);
newModules = cellfun(@char, newModules, 'UniformOutput', false);

%% Remove large (i.e. size >= N/2) modules
[newModules, newNetwork] = removeLargeModules(newModules, newNetwork);
end