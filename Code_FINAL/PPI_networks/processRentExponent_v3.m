function [Empirical_rent, b2, R2, randomMod_rent, randomEdge_rent, ...
    random_mod_edge_rent, h, p, x, y, randModx, randMody, ...
    randEdgex, randEdgey, randBothx, randBothy] ...
    = processRentExponent_v3(modules, network)
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

%% Randomization tests
type_of_connections = 2;                                                    % 1 gives internal connections; 2 gives external connections; 3 gives total
x = numberModularNodes;
y = numberExternalConnections;
[Empirical_rent, b2, MSE, R2] = logfit(x, y, 'loglog');
% Save averages here
randomMod_rent = nan(100,1);
randomEdge_rent = nan(100,1);
random_mod_edge_rent = nan(100,1);
% Save original values here
randModx = zeros(length(numberModularNodes), 100);
randMody = zeros(length(numberModularNodes), 100);
randEdgex = zeros(length(numberModularNodes), 100);
randEdgey = zeros(length(numberModularNodes), 100);
randBothx = zeros(length(numberModularNodes), 100);
randBothy = zeros(length(numberModularNodes), 100);

parfor t = 1:100
    [x1, y1] = randomizeModules(nodesCombined, specificConnections, type_of_connections, modules, network);
    [x2, y2] = randomizeEdges(nodesCombined, specificConnections, type_of_connections, network);
    [x3, y3] = randomize_modules_edges(nodesCombined, specificConnections, type_of_connections, modules, network);

    randModx(:,t) = x1;
    randMody(:,t) = y1;
    randEdgex(:,t) = x2;
    randEdgey(:,t) = y2;
    randBothx(:,t) = x3;
    randBothy(:,t) = y3;

    % Call logfit, with 'loglog', and keep b2 constrained
    mod_rent = logfit_b2_constraint(x1,y1,b2);
    edge_rent = logfit_b2_constraint(x2,y2,b2);
    mod_edge_rent = logfit_b2_constraint(x3,y3,b2);
    
    randomMod_rent(t) = mod_rent;
    randomEdge_rent(t) = edge_rent;
    random_mod_edge_rent(t) = mod_edge_rent;
    t
end

%% Stats Tests; they have passed Lilliefors Tests
[h1,p1] = ttest(randomMod_rent, Empirical_rent);
[h2,p2] = ttest(randomEdge_rent, Empirical_rent);
[h3,p3] = ttest(random_mod_edge_rent, Empirical_rent);

[h4,p4] = ttest2(randomEdge_rent, randomMod_rent);
[h5,p5] = ttest2(randomEdge_rent, random_mod_edge_rent);
[h6,p6] = ttest2(randomMod_rent, random_mod_edge_rent);

h = [h1, h2, h3, h4, h5, h6];
p = [p1, p2, p3, p4, p5, p6];

end
