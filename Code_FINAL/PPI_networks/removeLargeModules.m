function [newModules, newNetwork] = removeLargeModules(newModules, newNetwork)
%% Remove modules size > N/2
nodesCombined = makeNodesCombined(newModules);
sizes_of_modules = zeros(length(nodesCombined),1);
for t = 1:length(nodesCombined)
    sizes_of_modules(t) = nodesCombined{t}.size();
end
max_size = max(sizes_of_modules);
marks = find(sizes_of_modules >= max_size/2);
newModules(marks,:) = [];

%% Make nodesCombined
nodesCombined = makeNodesCombined(newModules);
uniqueNodes = cell(1,1);
count = 1;
for t = 1:length(nodesCombined)
    nodes_array = java.util.ArrayList;
    nodes_array.addAll(nodesCombined{t});
    for k = 1:nodes_array.size()
        NOI = char(nodes_array.get(k-1));
        if sum(strcmp(NOI, uniqueNodes(:,1))) == 0
            uniqueNodes{count,1} = NOI;
            count = count + 1;
        end
    end
    sizes_of_modules(t) = nodesCombined{t}.size();
end

%% Fix modules and networks; start with networks, since I fixed modules already
numModules = 1;
numEdges = 1;
metricModules = 9;
metricEdges = 9;
% It will do this at least 1 time
while numModules ~= metricModules || numEdges ~= metricEdges
    % Old, or current, values
    numModules = size(newModules,1);
    numEdges = size(newNetwork,1);

    newNetwork = processNetwork(newNetwork, newModules);                    % If not in modules, remove from network
    newNetwork = strtrim(newNetwork);
    newModules = processModules(newNetwork, newModules);                    % If not in network, remove from modules
    newModules = strtrim(newModules);
    newModules = cellfun(@char, newModules, 'UniformOutput', false);
    
    % New values
    metricModules = size(newModules,1);
    metricEdges = size(newNetwork,1);
end