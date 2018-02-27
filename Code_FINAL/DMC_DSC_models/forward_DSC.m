function out = forward_DSC(uniqueNodes, modules, mods_per_all_nodes, qmod, qcon, pfav)
import java.util.*
import java.lang.*
%% Randomly connect two proteins in each module
specificConnections = cell(1,2);
count = 1;
for t = 1:size(modules,1)
    MOI = modules(t,2:end);
    MOI = MOI(~cellfun('isempty', MOI));
    rand_num1 = randi(length(MOI));
    rand_num2 = randi(length(MOI));
    while rand_num1 == rand_num2
        rand_num1 = randi(length(MOI));
    end
    
    nodeA = MOI(rand_num1);
    nodeB = MOI(rand_num2);
    
    index = 0;
    if count >= 2
        [~, index] = ismember(nodeA, specificConnections(:,1));
    end
    
    if index == 0
        specificConnections(count,1) = nodeA;
        specificConnections(count,2) = java.util.HashSet;
        specificConnections{count,2}.add(char(nodeB));
        count = count + 1;
    else
        specificConnections{index,2}.add(char(nodeB));
    end
    
    index = 0;
    if count >= 2
        [~, index] = ismember(nodeB, specificConnections(:,1));
    end
    
    if index == 0
        specificConnections(count,1) = nodeB;
        specificConnections(count,2) = java.util.HashSet;
        specificConnections{count,2}.add(char(nodeA));
        count = count + 1;
    else
        specificConnections{index,2}.add(char(nodeA));
    end
end
%% DSC model
firm_modules_set = java.util.HashSet;
for t = 1:size(modules,1)
    firm_modules_set.add(char(modules(t,1)));
end

numNodes = length(specificConnections);
available_nodes = setdiff(uniqueNodes, specificConnections(:,1));
while numNodes < length(uniqueNodes)
    % Choose some node from the unconnected nodes
    rand_num = randi(length(available_nodes));
    NOI_1 = available_nodes(rand_num);
    NOI_1 = char(NOI_1);
    
    % Find its modules
    index = strcmp(NOI_1, mods_per_all_nodes(:,1));
    
    % List of modules that NOI_1 is in
    set = java.util.HashSet;
    set.addAll(mods_per_all_nodes{index,2});
    
    modules_set = java.util.HashSet;
    modules_set.addAll(firm_modules_set);
       
    % We decide to choose to connect this NOI_1 to a node in its module, or
    % to some other module
    choice = [0 1];
    choice = choice(randp([1-pfav pfav]));
    % If 1, we choose a node in its module
    if choice == 1
        modules_to_choose_from = set.toArray();
    else
        modules_set.removeAll(set);
        modules_to_choose_from = modules_set.toArray();
    end
    
    % Choose the module from which NOI_2 will be drawn
    rand_num = randi(modules_to_choose_from.length);
    MOI = modules_to_choose_from(rand_num);
    
    [~, index] = ismember(MOI, modules(:,1));
    set_nodes = modules(index,2:end);
    set_nodes = set_nodes(~cellfun('isempty', set_nodes));
    % Choose the node from the list of nodes that are part of the connected
    % network. Useful nodes are in the correct module(s) and connected
    useful_nodes = intersect(set_nodes, specificConnections(:,1));

    rand_num = randi(length(useful_nodes));
    NOI_2 = useful_nodes(rand_num);
    % Just in case it's the same node, because we avoid self-edges
    while strcmp(NOI_1, NOI_2) == 1
        rand_num = randi(length(useful_nodes));
        NOI_2 = useful_nodes(rand_num);
    end
    
    % DSC Model finally applied
    anchor = char(NOI_2);
    recent = char(NOI_1);
    % Determine which neighbors of the anchor will be assigned to the
    % recent node
    [~, index] = ismember(anchor, specificConnections(:,1));
    neighbors_of_anchor = java.util.HashSet;
    neighbors_of_anchor.addAll(specificConnections{index,2});
    neighbors_of_anchor = neighbors_of_anchor.toArray();
    
    for f = 1:neighbors_of_anchor.length
        temp_NOI = char(neighbors_of_anchor(f));
        
        % Choose to modify edge based on qmod; modify means choice = 1.
        choice = [0 1];
        choice = choice(randp([1-qmod qmod]));
                
        if choice == 1
            % The proportion of shared modules between anchor/recent and
            % temp_NOI dictates who keeps/gets temp_NOI.
            % If det_num = 1, then recent node gets temp_NOI; else, the
            % anchor keeps temp_NOI
            [~, ind1] = ismember(anchor, mods_per_all_nodes(:,1));
            [~, ind2] = ismember(recent, mods_per_all_nodes(:,1));
            [~, comp] = ismember(temp_NOI, mods_per_all_nodes(:,1));
            
            set1 = java.util.HashSet;
            set2 = java.util.HashSet;
            comp_set = java.util.HashSet;
            set1.addAll(mods_per_all_nodes{ind1,2});
            set2.addAll(mods_per_all_nodes{ind2,2});
            comp_set.addAll(mods_per_all_nodes{comp,2});
            
            set1.retainAll(comp_set);
            set2.retainAll(comp_set);
            
            % If the recent node has more shared modules with temp_NOI, it
            % gets the edge, instead of the anchor node.
            set1_comp = set1.size();
            set2_comp = set2.size();
            det_num = 2;
            if set1_comp < set2_comp
                det_num = 1;
            end
            
            % A chance that anchor-temp_NOI or recent-temp_NOI edges
            % will be deleted/not formed
            if det_num == 1
                % Remove edge from anchor to NOI, and vice-versa.
                [~, index] = ismember(anchor, specificConnections(:,1));
                specificConnections{index,2}.remove(temp_NOI);
                [~, index] = ismember(temp_NOI, specificConnections(:,1));
                specificConnections{index,2}.remove(anchor);
                
                % Add edge from recent to NOI, and vice-versa.
                [~, index] = ismember(recent, specificConnections(:,1));
                if index ~= 0
                    specificConnections{index,2}.add(char(temp_NOI));
                else
                    specificConnections(count,1) = cellstr(recent);
                    specificConnections(count,2) = java.util.HashSet;
                    specificConnections{count,2}.add(char(temp_NOI));
                    count = count + 1;
                end
                
                % Add recent to temp_NOI connections.
                [~, index] = ismember(temp_NOI, specificConnections(:,1));
                specificConnections{index,2}.add(char(recent));
            else
                % Remove edge from recent to NOI, and vice-versa. Keep
                % anchor to NOI connection. If the recent to NOI 
                % connection already existed prior to this duplication, it 
                % is still vulnerable to divergence here
                [~, index] = ismember(recent, specificConnections(:,1));
                if index ~= 0
                    specificConnections{index,2}.remove(temp_NOI);
                    [~, index] = ismember(temp_NOI, specificConnections(:,1));
                    specificConnections{index,2}.remove(recent);
                end
            end
        else
            % Add temp_NOI to recent's connections, and do not modify
            [~, index] = ismember(recent, specificConnections(:,1));
            if index ~= 0
                specificConnections{index,2}.add(char(temp_NOI));
            else
                specificConnections(count,1) = cellstr(recent);
                specificConnections(count,2) = java.util.HashSet;
                specificConnections{count,2}.add(char(temp_NOI));
                count = count + 1;
            end
            % Add recent to temp_NOI connections.
            [~, index] = ismember(temp_NOI, specificConnections(:,1));
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
        [~, index] = ismember(anchor, specificConnections(:,1));
        specificConnections{index,2}.add(char(recent));
        [~, index] = ismember(recent, specificConnections(:,1));

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