function [Empirical_rent, b2, R2, randomMod_rent, randomEdge_rent, ...
    random_mod_edge_rent, h, p, x, y, av_x, av_y, randModx, randMody, ...
    randEdgex, randEdgey, randBothx, randBothy] ...
    = processRentExponent_v3_gotermfinder(modules, network)
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

%% Clear things
uniqueNodes = unique(network(:));
network_size = length(network);
list_modules = modules(:,1);
clearvars -except numberModularNodes numberExternalConnections ...
    uniqueNodes nodesCombined specificConnections modules network_size ...
    list_modules

%% Randomization tests
type_of_connections = 2;                                                    % 1 gives internal connections; 2 gives external connections; 3 gives total
x = numberModularNodes;
y = numberExternalConnections;
[av_x, av_y] = average_modules(x,y);
[Empirical_rent, b2, MSE, R2] = logfit(av_x, av_y, 'loglog');

poolobj = parpool(32);

num_iterations = 100;
randomMod_rent = nan(num_iterations,1);
randomEdge_rent = nan(num_iterations,1);
random_mod_edge_rent = nan(num_iterations,1);

randModx = zeros(length(numberModularNodes), num_iterations);
randMody = zeros(length(numberModularNodes), num_iterations);
randEdgex = zeros(length(numberModularNodes), num_iterations);
randEdgey = zeros(length(numberModularNodes), num_iterations);
randBothx = zeros(length(numberModularNodes), num_iterations);
randBothy = zeros(length(numberModularNodes), num_iterations);

%% Parallel calculations of Rent's exponent
nc = parallel.pool.Constant(nodesCombined);
sc = parallel.pool.Constant(specificConnections);
un = parallel.pool.Constant(uniqueNodes);
lm = parallel.pool.Constant(list_modules);


parfor t = 1:num_iterations
    [x1, y1] = randomizeModules(nc.Value, sc.Value, type_of_connections, lm.Value, un.Value);    
    [x2, y2] = randomizeEdges(nc.Value, sc.Value, type_of_connections, network_size);  
    [x3, y3] = randomize_modules_edges(nc.Value, sc.Value, type_of_connections, lm.Value, un.Value, network_size);
    
    randModx(:,t) = x1;
    randMody(:,t) = y1;
    randEdgex(:,t) = x2;
    randEdgey(:,t) = y2;
    randBothx(:,t) = x3;
    randBothy(:,t) = y3;
    % Average external edges of all the modules of one size, for each size
    [av_x1, av_y1] = average_modules(x1,y1);
    [av_x2, av_y2] = average_modules(x2,y2);
    [av_x3, av_y3] = average_modules(x3,y3);
    mod_rent = logfit_b2_constraint(av_x1,av_y1,b2);
    edge_rent = logfit_b2_constraint(av_x2,av_y2,b2);
    mod_edge_rent = logfit_b2_constraint(av_x3,av_y3,b2);
    
    randomMod_rent(t) = mod_rent;
    randomEdge_rent(t) = edge_rent;
    random_mod_edge_rent(t) = mod_edge_rent;
    t
end
delete(poolobj)

%% Stats Test
[h1,p1] = ttest(randomMod_rent, Empirical_rent);
[h2,p2] = ttest(randomEdge_rent, Empirical_rent);
[h3,p3] = ttest(random_mod_edge_rent, Empirical_rent);
[h4,p4] = ttest2(randomEdge_rent, randomMod_rent);
[h5,p5] = ttest2(randomEdge_rent, random_mod_edge_rent);
[h6,p6] = ttest2(randomMod_rent, random_mod_edge_rent);

h = [h1, h2, h3, h4, h5, h6];
p = [p1, p2, p3, p4, p5, p6];

end
