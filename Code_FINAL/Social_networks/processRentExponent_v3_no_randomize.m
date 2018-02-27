function [Empirical_rent, b2, R2, x, y] ...
    = processRentExponent_v3_no_randomize(modules, network)
import java.util.*;
import java.lang.*;
%% Change modules into cell array of HashSets
% Each HashSet has all nodes in one module
nodesCombined = makeNodesCombined(modules);

%% Find all connections for each node
% We address double edges (i.e. if row 1 says node F - node G, and row 22
% says node G - node F) here. The change is in specificConnections, not the
% original network
specificConnections = makeSpecificConnections(network);

%% Find out how many connections are external (i.e. not inside module)    
[numberInternalConnections, numberExternalConnections, numberTotalConnections] = findConnections_fast(nodesCombined, specificConnections);

%% Number of nodes in each module
numberModularNodes = nan(length(nodesCombined),1);
for j = 1:length(nodesCombined)
    numberModularNodes(j) = nodesCombined{j}.size();
end

%% Finish the calculations
type_of_connections = 2;                                                    % 1 gives internal connections; 2 gives external connections; 3 gives total
x = numberModularNodes;
y = numberExternalConnections;
[Empirical_rent, b2, MSE, R2] = logfit(x, y, 'loglog');

end