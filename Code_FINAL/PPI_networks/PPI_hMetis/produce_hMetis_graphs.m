% Format networks for use in sshMetis
% REVIGO cut-off
cut_off = 50;
cd('/Users/How/Documents/Saket Navlakha/Rent_2017/Official Rents/Results_v6/PPI/')
list_PPI_files = dir(strcat('*', int2str(cut_off), '.mat'));

for t = 1:length(list_PPI_files)
    file_name = list_PPI_files(t).name;
    % Variable freeNet is the non-redundant network
    load(file_name, 'freeNet')
    network = freeNet;
    unique_nodes = unique(network(:));
    num_edges = size(network,1);
    num_vertices = length(unique_nodes);
    
    write_network = cell(size(network));
    
    for h = 1:length(unique_nodes)
        % Nodes are assigned numbers for shMetis; the number is their
        % position in this list
        node = unique_nodes(h);
        
        inds_one = find(strcmp([network(:,1)], node));
        inds_two = find(strcmp([network(:,2)], node));
        
        if ~isempty(inds_one)
            write_network(inds_one,1) = {h};
        end
        if ~isempty(inds_two)
            write_network(inds_two,2) = {h};
        end
    end

    ind = strfind(file_name, '.');
    name = strcat(file_name(1:ind-1), '_hMetis.txt');
    
    colA = [write_network{:,1}]';
    colB = [write_network{:,2}]';
    
    fid=fopen(name,'w');
    fprintf(fid, [int2str(num_edges) ' ' int2str(num_vertices) '\n']);
    fprintf(fid, '%d %d \n', [colA colB]');
    fclose(fid);
end