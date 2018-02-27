function out = removeRedundantNet(network)
% Remove redundant edges
newNetwork = cell(size(network));
newNetwork(1,:) = network(1,:);
count = 1;
for t = 2:length(network)
    % Has this combination been found before?
    nodeA = network(t,1);
    nodeB = network(t,2);
    % Check for an edge labeled: nodeA-nodeB, or nodeB-nodeA
    check2 = find(strcmp(nodeA, newNetwork(:,2)));
    check1 = find(strcmp(nodeA, newNetwork(:,1)));
    % Variable check2 means that nodeA is in column 2, so find its partners
    % in column 1
    partnersInColm1 = newNetwork(check2,1);
    partnersInColm2 = newNetwork(check1,2);
    
    checkA = ~isempty(find(strcmp(nodeB, partnersInColm1)));
    checkB = ~isempty(find(strcmp(nodeB, partnersInColm2)));
    
    % Check = 1 when the pattern, or edge, has been found before
    check = checkA || checkB;
    if ~check
        newNetwork(count,1) = network(t,1);
        newNetwork(count, 2) = network(t,2);
        count = count + 1;
    end
end

newNetwork( all(cellfun(@isempty,newNetwork),2), : ) = [];
out = newNetwork;
end