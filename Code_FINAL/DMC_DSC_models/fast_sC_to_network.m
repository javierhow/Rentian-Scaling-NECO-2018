function out = fast_sC_to_network(sC)
% Convert specificConnections to network form, where each row is an edge,
% and there are two columns, one per node of the edge
import java.lang.*;

network = cell(size(sC));
count = 1;
previous_nodes = java.util.HashSet;

for g = 1:length(sC)
    NOI = sC{g,1};
    temp_list = sC{g, 2};
    
    h = 1;
    while h <= temp_list.size()
        useful_list = temp_list.toArray();
        node = useful_list(h);
        if ~strcmp(NOI, node) && ~previous_nodes.contains(node)
            network{count,1} = NOI;
            network{count,2} = node;
            count = count + 1;
        end
        h = h + 1;
    end
    previous_nodes.add(NOI);
end

network(all(cellfun(@isempty,network),2), : ) = [];

out = network;

end