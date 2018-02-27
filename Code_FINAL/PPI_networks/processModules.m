function newModules = processModules(network, modules)
%% Not all nodes remain after processNetwork, so modify modules accordingly
newModules = cell(size(modules));
newModules(:,1) = modules(:,1);

uniqueNodes = unique(network(:));
uniqueNodes = strtrim(uniqueNodes);
for j = 1:size(modules,1)
    tempModule = strtrim(modules(j,2:end));
    commonNodes = intersect(tempModule, uniqueNodes);
    newModules(j,2:length(commonNodes)+1) = commonNodes;
end

end