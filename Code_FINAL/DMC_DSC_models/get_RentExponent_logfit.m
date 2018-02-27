function [Empirical_rent, b2, MSE, R2, x, y] = get_RentExponent_logfit(modules, specificConnections)
import java.util.*;
import java.lang.*;
%% Make modules useful
nodesCombined = makeNodesCombined(modules);
%% Find out how many connections are external (i.e. not inside module)    
[numberInternalConnections, numberExternalConnections, numberTotalConnections] = findConnections_fast(nodesCombined, specificConnections);
%% Number of nodes in each module
numberModularNodes = nan(length(nodesCombined),1);
for j = 1:length(nodesCombined)
    numberModularNodes(j) = nodesCombined{j}.size();
end

%% Calculate Rent's exponent
x = numberModularNodes;
y = numberExternalConnections;
[Empirical_rent, b2, MSE, R2] = logfit(x, y, 'loglog');

end