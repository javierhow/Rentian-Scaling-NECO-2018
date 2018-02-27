function specificConnections = makeSpecificConnections(network)
% From processRentExponent_v3
import java.lang.*;
import java.util.*;
%% Find all connections for each node
% We address double edges (i.e. if row 1 says node F - node G, and row 22
% says node G - node F) here. The change is in specificConnections, not the
% original network
nodes = strtrim(unique(network(:)));                                        % It's necessary to do network(:), because some particular nodes are in the second column
specificConnections = cell(length(nodes),2);
specificConnections(:,1) = nodes;
for n=1:length(nodes)
    tempSet = java.util.HashSet;
    indexes = find(strcmp(network(:,1), nodes(n)));
    
    if ~isempty(indexes)                                                    % This means that the node is in column 1, so proceed as normal
        neighbours = network(indexes, 2);
        for k = 1:length(neighbours)
            tempSet.add(strtrim(neighbours{k}));
        end
        specificConnections(n,2) = tempSet.clone(); 
        
        indexes = strcmp(network(:,2), nodes(n));                           % Node might be in column 2, however
        if ~isempty(indexes)
            neighbours = network(indexes, 1);
            for k = 1:length(neighbours)
                specificConnections{n,2}.add(strtrim(neighbours{k}));
            end
        else
        end    
    else                                                                    % Node is only in column 2
        indexes = strcmp(network(:,2), nodes(n));        
        neighbours = network(indexes, 1);
        for k = 1:length(neighbours)
            tempSet.add(strtrim(neighbours{k}));
        end
        specificConnections(n,2) = tempSet.clone();  
    end
end

end