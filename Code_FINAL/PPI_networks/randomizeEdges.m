function [x, y] = randomizeEdges(nodesCombined, specificConnections, typeOfConnection, network_length)
import java.util.*;
import java.lang.*;

newSpecificConnections = cell(size(specificConnections));
newSpecificConnections(:,1) = specificConnections(:,1);
for t = 1:length(specificConnections)
    newSpecificConnections(t,2) = specificConnections{t,2}.clone();         % Else, you overwrite
end
clear specificConnections
t = 1;
while t <= network_length
    % Notation is nodes A-B and C-D. We want A-D and C-B.
    random1 = randi([1 length(newSpecificConnections)], 1, 1);
    random2 = randi([1 length(newSpecificConnections)], 1, 1);
    
    if random1 ~= random2
        nodeA = newSpecificConnections{random1, 1};
        nodeC = newSpecificConnections{random2, 1};
        partnersA = newSpecificConnections{random1, 2};
        partnersC = newSpecificConnections{random2, 2};
        
        random3 = randi([1 partnersA.size()], 1, 1);
        random4 = randi([1 partnersC.size()], 1, 1);
        tempArray = partnersA.clone().toArray();
        nodeB = tempArray(random3);
        tempArray = partnersC.clone().toArray();
        nodeD = tempArray(random4);
        
        indexB = strcmp(nodeB, newSpecificConnections(:,1));
        indexD = strcmp(nodeD, newSpecificConnections(:,1));
        partnersB = newSpecificConnections{indexB, 2};
        partnersD = newSpecificConnections{indexD, 2};
        
        % Once sufficiently randomized, you might have a set of neighbours
        % that contain the node you plan on adding or removing. No way
        % around it, so we just check; if yes, then we move on. For example,
        % Node A may already be connected to Node D, so that connection 
        % would be redundant. Hence, the if statement.
        if partnersA.contains(nodeD) || partnersC.contains(nodeB) || partnersD.contains(nodeA) || partnersB.contains(nodeC)
            % Do nothing
        elseif strcmp(nodeA, nodeD) || strcmp(nodeC, nodeB) || strcmp(nodeD, nodeA) || strcmp(nodeB, nodeC) 
            % Do nothing
            % The new node (eg node D) might be the same node as the
            % one to which we will connect (eg node A). We have to avoid
            % creating a self-edge
        else            
            % Additions
            partnersA.add(nodeD);
            partnersB.add(nodeC);
            partnersC.add(nodeB);
            partnersD.add(nodeA);
            
            % Deletions
            partnersA.remove(nodeB);
            partnersB.remove(nodeA);
            partnersC.remove(nodeD);
            partnersD.remove(nodeC);

            t = t + 1;     
        end
    end
end

%% Find out how many connections are external (i.e. not inside module) 
% Note that we use same modules, but with novel edges
[numberInternalConnections, numberExternalConnections, numberTotalConnections] = findConnections_fast(nodesCombined, newSpecificConnections);

%% Number of nodes in each module
numberModularNodes = nan(length(nodesCombined),1);
for j = 1:length(nodesCombined)
    numberModularNodes(j) = nodesCombined{j}.size();
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