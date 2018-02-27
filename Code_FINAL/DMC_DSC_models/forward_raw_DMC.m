function out = forward_raw_DMC(uniqueNodes, modules, mods_per_all_nodes, qmod, qcon)
import java.util.*
import java.lang.*
%% Randomly connect two proteins in each module
% Slightly different from forward_DSC.m, but it produces the same results.
% The difference is forward_DSC.m uses ismember, while this code uses
% strcmp, to find matches
specificConnections = cell(1,2);
count = 1;
for t = 1:size(modules,1)
    MOI = modules(t,2:end);
    indeces = strcmp('', MOI);
    MOI = MOI(~indeces);
    MOI = MOI(~cellfun('isempty', MOI));
    rand_num1 = randi(length(MOI));
    rand_num2 = randi(length(MOI));
    while rand_num1 == rand_num2
        rand_num1 = randi(length(MOI));
    end
    
    nodeA = MOI(rand_num1);
    nodeB = MOI(rand_num2);
    
    index = strcmp(nodeA, specificConnections(:,1));
    
    if sum(index) == 0
        specificConnections(count,1) = nodeA;
        specificConnections(count,2) = java.util.HashSet;
        specificConnections{count,2}.add(char(nodeB));
        count = count + 1;
    else
        specificConnections{index,2}.add(char(nodeB));
    end
    
    index = strcmp(nodeB, specificConnections(:,1));
    
    if sum(index) == 0
        specificConnections(count,1) = nodeB;
        specificConnections(count,2) = java.util.HashSet;
        specificConnections{count,2}.add(char(nodeA));
        count = count + 1;
    else
        specificConnections{index,2}.add(char(nodeA));
    end
end
    
%% Raw DMC model
numNodes = length(specificConnections);
available_nodes = setdiff(uniqueNodes, specificConnections(:,1));
while numNodes < length(uniqueNodes)
    % Choose some node from the unconnected nodes
    rand_num = randi(length(available_nodes));
    NOI_1 = available_nodes(rand_num);
    NOI_1 = char(NOI_1);
    
    % Useful nodes are connected
    useful_nodes = specificConnections(:,1);
    rand_num = randi(length(useful_nodes));
    NOI_2 = useful_nodes(rand_num);
    
    % Just in case it's the same node, because we avoid self-edges
    while strcmp(NOI_1, NOI_2) == 1
        rand_num = randi(length(useful_nodes));
        NOI_2 = useful_nodes(rand_num);
    end
    
    % DMC Model applied
    anchor = char(NOI_2);
    recent = char(NOI_1);
    % Determine which neighbors of anchor the recent node will accept
    index = strcmp(anchor, specificConnections(:,1));
    neighbors_of_anchor = java.util.ArrayList;
    neighbors_of_anchor.addAll(specificConnections{index,2});
    
    for f = 1:neighbors_of_anchor.size()
        % Choose to modify edge based on qmod; modify means choice = 1.
        choice = [0 1];
        choice = choice(randp([1-qmod qmod]));
        
        temp_NOI = char(neighbors_of_anchor.get(f-1));
        
        % Choice = 1, we modify one of two edges
        if choice == 1
            rand_num = randi(2);
            % 50-50 chance that anchor-temp_NOI or recent-temp_NOI edge
            % will be deleted or not formed, respectively
            if rand_num == 1
                % Remove edge from anchor to NOI, and vice-versa
                index = strcmp(anchor, specificConnections(:,1));
                specificConnections{index,2}.remove(temp_NOI);
                index = strcmp(temp_NOI, specificConnections(:,1));
                specificConnections{index,2}.remove(anchor);
                % Add edge from recent to NOI, and vice-versa
                index = strcmp(recent, specificConnections(:,1));
                if sum(index) > 0
                    specificConnections{index,2}.add(char(temp_NOI));
                else
                    specificConnections(count,1) = cellstr(recent);
                    specificConnections(count,2) = java.util.HashSet;
                    specificConnections{count,2}.add(char(temp_NOI));
                    count = count + 1;
                end
                % Add recent to temp_NOI connections.
                index = strcmp(temp_NOI, specificConnections(:,1));
                specificConnections{index,2}.add(char(recent));
            else
                % Remove edge from recent to NOI, and vice-versa. Keep
                % anchor to NOI connection. If the recent to NOI 
                % connection already existed prior to this duplication, it 
                % is still vulnerable to divergence here
                index = strcmp(recent, specificConnections(:,1));
                if sum(index) > 0
                    specificConnections{index,2}.remove(temp_NOI);
                    index = strcmp(temp_NOI, specificConnections(:,1));
                    specificConnections{index,2}.remove(recent);
                end 
            end
        else
            % Add temp_NOI to recent's connections, and do not modify
            index = strcmp(recent, specificConnections(:,1));
            if sum(index) > 0
                specificConnections{index,2}.add(char(temp_NOI));
            else
                specificConnections(count,1) = cellstr(recent);
                specificConnections(count,2) = java.util.HashSet;
                specificConnections{count,2}.add(char(temp_NOI));
                count = count + 1;
            end
            % Add recent to temp_NOI connections
            index = strcmp(temp_NOI, specificConnections(:,1));
            specificConnections{index,2}.add(char(recent));
        end
        
    end
    
    % Add connection between anchor and recent (this depends on qcon)
    choice = [0 1];
    choice = choice(randp([1-qcon qcon]));
    % If choice = 1, we add; otherwise, we do nothing (note that if the
    % connection already exists then we do nothing to it, because qcon is
    % for an anchor-recent duplication only)
    if choice == 1
        index = strcmp(anchor, specificConnections(:,1));
        specificConnections{index,2}.add(char(recent));
        index = strcmp(recent, specificConnections(:,1));
        % Correct
        if sum(index) == 0
            specificConnections(count,1) = cellstr(recent);
            specificConnections(count,2) = java.util.HashSet;
            specificConnections{count,2}.add(anchor);
            count = count + 1;
        else
            specificConnections{index,2}.add(anchor);
        end
    end
    numNodes = length(specificConnections);
    available_nodes = setdiff(uniqueNodes, specificConnections(:,1));
end
out = specificConnections;
end