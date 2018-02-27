function output = listModulesperNode_all(nodesCombined, list_modules, uniqueNodes)
import java.util.*;
import java.lang.*;
%% Lovely matrix of which modules each node is in; only indeces of the modules found, not actual name
modules_perNode = cell(length(uniqueNodes),2);
modules_perNode(:,1) = uniqueNodes;
for t = 1:length(uniqueNodes)
    tempNode = char(uniqueNodes(t));
    accumulateModules = cell(length(nodesCombined),1);
    for r = 1:length(nodesCombined)
        tempModule = nodesCombined{r};
        check = tempModule.contains(tempNode);
        if check
            accumulateModules(r) = list_modules(r);
        end
    end
    accumulateModules = accumulateModules(~cellfun('isempty', accumulateModules));
    if ~isempty(accumulateModules)
        modules_perNode{t,2} = accumulateModules;      
    end
end

output = modules_perNode;
end