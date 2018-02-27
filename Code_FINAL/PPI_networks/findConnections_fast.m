function [x, y, z] = findConnections_fast(nodesCombined, specificConnections)
import java.util.*;
import java.lang.*;

numberInternalSet = nan(length(nodesCombined), 1);
numberExternalSet = nan(length(nodesCombined), 1);

listNOIs = specificConnections(:,1);

for t = 1:length(nodesCombined)                                             % Go through each module
    tempCountExternalList = 0;
    tempCountInternalList = 0;
    
    setA = nodesCombined{t}.clone();                                        % List of nodes in module of interest (MOI)
    
    % We have to use a list to allow duplicates, since two different NOIs
    % might connect to the same node, and each connection is external
    listA = java.util.ArrayList;
    
    it = setA.iterator();
    while it.hasNext()                                                      % Go through nodes in MOI
        tempNodeX = it.next();                                              % Node Of Interest (NOI) in MOI
        % REDUNDANT; used in the next line, to check that NOI
        % Just checking that tempNodeX, our NOI in MOI, is in the list.
        % Furthermore, we get its index in the listNOIs, which also
        % corresponds to its index in specificConnections (since listNOIs
        % is based on specificConnections)
        indexNode = strcmp(listNOIs, tempNodeX);      
        
        if sum(indexNode) > 0
            setB = specificConnections{indexNode, 2}.clone();               % All the nodes that NOI connects to        
        else
            setB = java.util.HashSet;
        end
        
        % Add every node that NOI connects to into listA
        listA.addAll(setB);
    end
        
    % Remove from listA all instances of all nodes that are already in MOI
    % List B is a non-shallow copy of list A
    listB = java.util.ArrayList;
    listB.addAll(listA);
    % List A has all external nodes
    listA.removeAll(setA);
    % List B has the intersect between connections and nodes in MOI; hence,
    % it is (twice) as large as the number of internal connections
    listB.retainAll(setA);
    
    numberInternalSet(t) = listB.size()/2;
    numberExternalSet(t) = listA.size();
    
end

x = numberInternalSet;
y = numberExternalSet;
z = x + y;
end