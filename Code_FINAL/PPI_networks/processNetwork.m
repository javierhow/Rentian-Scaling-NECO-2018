function newNetwork = processNetwork(network, modules)
newNetwork = cellfun(@char, network, 'UniformOutput', false);

% Find every node involved in any module; necessary because not every node
% (eg protein) is mapped to a module, likely because they're not annotated
all_nodes = modules(:,2:end);
all_nodes = unique(all_nodes(:));
all_nodes = strtrim(all_nodes);

% If the node, in column 1 or 2 of the network, is not in any module, then
% empty the row of that specific edge
% Furthermore, if there is a self-edge (eg Node A - Node A, as in the case
% of dmc1), then remove that edge

for j = 1:length(newNetwork)
    a = strtrim(newNetwork(j,:));    
    index1 = find(strcmp(a(1), all_nodes),1);
    index2 = find(strcmp(a(2), all_nodes),1);
    if isempty(index1) || isempty(index2) || strcmp(a(1), a(2))
        newNetwork(j,:) = {[],[]};
    end
end

% Remove empty rows (ie edges)
newNetwork(all(cellfun('isempty', newNetwork),2),:) = [];
end