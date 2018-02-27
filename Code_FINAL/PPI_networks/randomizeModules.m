function [x, y] = randomizeModules(nodesCombined, specificConnections, typeOfConnection, list_modules, uniqueNodes)
%% Assign random nodes, with replacement, to each module. Same number assigned.
import java.util.*;
import java.lang.*;
newNodesCombined = cell(length(nodesCombined), 1);
%% Main code
%% Make copy, and find the sizes for each module.
% Helps in choosing which modules to switch around using randp, since
% bigger modules should be switched around more
tempsize = 0;
listSizes = zeros(size(newNodesCombined));
for t = 1:length(newNodesCombined)
    newNodesCombined(t) = nodesCombined{t}.clone();
    listSizes(t) = newNodesCombined{t}.size();
    tempsize = tempsize + newNodesCombined{t}.size();
end

%% Processing
% Column 1 column has a list of nodes, one per row; the next column has a
% HashSet of modules that the node is in
listOfModules = listModulesperNode_all(nodesCombined, list_modules, uniqueNodes);
clear nodesCombined
t = 0;
while t < tempsize
    % Pick two random nodes
    rand1 = randi([1 length(listOfModules)],1,1);
    rand2 = randi([1 length(listOfModules)],1,1);
    
    if rand1 ~= rand2
        nodeA = strtrim(listOfModules(rand1,1));
        nodeB = strtrim(listOfModules(rand2,1));
        % Modules that nodeA is in, and modules that nodeB is in
        modulesA = listOfModules{rand1,2};
        modulesB = listOfModules{rand2,2};
        % newForA_all has all modules that node B is in, but node A is not.
        % meanwhile, newForB_all has modules that A is in, but not B.
        newForA_all = setdiff(modulesB, modulesA);
        newForB_all = setdiff(modulesA, modulesB);
        
        if ~isempty(newForA_all) && ~isempty(newForB_all)
            % Pick a random one of those modules that they don't share in
            % common. When we choose a module, it will be proportional to
            % how common it is. This way, bigger modules are more likely to
            % be chosen, which ensures that they're randomized well
            listProportionA = zeros(size(newForA_all));
            tempSize = 0;
            for u = 1:length(newForA_all)
                index = strcmp(newForA_all(u), list_modules);
                listProportionA(u) = listSizes(index);
                tempSize = tempSize + listSizes(index);
            end
            listProportionA = listProportionA/tempSize;

            listProportionB = zeros(size(newForB_all));
            tempSize = 0;
            for u = 1:length(newForB_all)
                index = strcmp(newForB_all(u), list_modules);
                listProportionB(u) = listSizes(index);
                tempSize = tempSize + listSizes(index);
            end
            listProportionB = listProportionB/tempSize;

            % Probability a module is chosen depends on its size relative
            % to all other modules
            indA = randp(listProportionA, 1, 1);
            indB = randp(listProportionB, 1, 1);
            newForA_single = newForA_all(indA);
            newForB_single = newForB_all(indB);
            % Indeces of this new module
            indexForA = strcmp(newForA_single, list_modules);
            indexForB = strcmp(newForB_single, list_modules);
            
            % indexForA has node B, and we will add A into it. Opposite for
            % node indexForB.
            nodeA = char(nodeA);
            nodeB = char(nodeB);
            if ~newNodesCombined{indexForB}.contains(nodeA)
                error('Modules improperly modified')
            elseif ~newNodesCombined{indexForA}.contains(nodeB)
                error('Modules improperly modified')
            else
            end
            newNodesCombined{indexForB}.remove(nodeA);
            newNodesCombined{indexForA}.remove(nodeB);
            newNodesCombined{indexForA}.add(nodeA);
            newNodesCombined{indexForB}.add(nodeB);
            
            % Update listOfModules, by accessing each node (rand1 and rand
            % 2 for nodeA and nodeB), and removing and adding the correct
            % module (i.e. nodeA's list now loses the module we swapped
            % out to, and gains the module we swapped in from, nodeB's 
            % list. Same for nodeB). This is important because we use
            % listOfModules at the beginning of this while loop.
            listOfModules{rand1,2} = setdiff(modulesA, newForB_single);
            listOfModules{rand1,2} = [listOfModules{rand1,2}; newForA_single];
            listOfModules{rand2,2} = setdiff(modulesB, newForA_single);
            listOfModules{rand2,2} = [listOfModules{rand2,2}; newForB_single];
            t = t + 1;
        else
            error('Modules not properly accessed')
        end
    end
end

%% Find out how many connections are external (i.e. not inside module) 
% Note that we use novel modules, but with the same edges
[numberInternalConnections, numberExternalConnections, numberTotalConnections] = findConnections_fast(newNodesCombined, specificConnections);

%% Number of nodes in each module
numberModularNodes = nan(length(newNodesCombined),1);
for j = 1:length(newNodesCombined)
    numberModularNodes(j) = newNodesCombined{j}.size();
end

%% Return correct type of connections
x = numberModularNodes;
if typeOfConnection == 1
    y = numberInternalConnections;
elseif typeOfConnection == 2
    y = numberExternalConnections;
elseif typeOfConnection == 3
    y = numberTotalConnections;
else
    error('Not a viable type of connection')
end
end