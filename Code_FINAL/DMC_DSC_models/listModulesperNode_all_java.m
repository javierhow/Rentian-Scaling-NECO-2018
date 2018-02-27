function output = listModulesperNode_all_java(nodesCombined, modules, network)
import java.util.*;
import java.lang.*;
%% Lovely matrix of which modules each node is in; only indeces of the modules found, not actual name
uniqueNodes = unique(network(:));
modules_perNode = cell(length(uniqueNodes),2);
modules_perNode(:,1) = uniqueNodes;
for t = 1:length(uniqueNodes)
    tempNode = char(uniqueNodes(t));
    accumulateModules = java.util.HashSet;
    for r = 1:length(nodesCombined)
        tempModule = nodesCombined{r};
        check = tempModule.contains(tempNode);
        if check && ~strcmp('', modules(r,1))
            accumulateModules.add(char(modules(r,1)));
        end
    end
    if accumulateModules.size() > 0
        modules_perNode{t,2} = accumulateModules;      
    end
end

output = modules_perNode;
end