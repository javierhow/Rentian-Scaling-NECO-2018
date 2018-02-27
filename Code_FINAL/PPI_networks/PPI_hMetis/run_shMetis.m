% Run shMetis, which is a Bash script
cd('/Users/How/Documents/Saket Navlakha/Rent_2017/Official Rents/Data sets/BIOGRID-ORGANISM-3/PPIs/hMetis')
% REVIGO cut-off
cutoff = 70;
% Networks have to be in hMetis format (.hgr)
files_to_get_txt = strcat('*', num2str(cutoff), '_hMetis.txt');
list_files_nets = dir(files_to_get_txt);
files_to_get_hgr = strcat('*', num2str(cutoff), '_hMetis.hgr.txt');
list_files_hgr = dir(files_to_get_hgr);

allowed_imbalance = 5;
% Path to hMetis
program_loc = '/Users/How/Documents/Saket\ Navlakha/Rent_2017/Official\ Rents/Code/hmetis-1.5-osx-i686/shmetis';

all_averages_nodes = cell(size(list_files_hgr));
all_averages_external_degrees = cell(size(list_files_hgr));
for t = 1:length(list_files_hgr)
    file_name = strcat(list_files_hgr(t).folder, '/', list_files_hgr(t).name);
    
    finished = 0;
    counter = 1;
    list_subnetworks = cell(counter*2,1);
    
    network_file = strcat(list_files_nets(t).folder, '/', list_files_nets(t).name);
    file_name = strrep(file_name, ' ', '\ ');
    
    % Variables to keep
    ave_nodes = [];
    ave_extDeg = [];
    
    while ~finished
        % Partition in half
        num_partitions = 2^counter;
        cmdStr = [program_loc ' ' file_name ' ' int2str(num_partitions) ' ' int2str(allowed_imbalance)];

        [status, cmdout] = system(cmdStr);
        % Pull out the average number of nodes and external degree
        [ave_num_nodes, ave_ext_degree, finished] = process_shMetis_results(cmdout)
        
        if ~finished
            ave_nodes = [ave_nodes; ave_num_nodes];
            ave_extDeg = [ave_extDeg; ave_ext_degree];
        end

        counter = counter + 1;
    end
    % Plot scatter on log-log scales
    figure
    loglog(ave_nodes, ave_extDeg)
    name = strsplit(list_files_hgr(t).name, '_');
    title(name{1})
    all_averages_nodes{t} = ave_nodes;
    all_averages_external_degrees{t} = ave_extDeg;
end
% Save
save_as_file = ['/Users/How/Documents/Saket Navlakha/Rent_2017/Official Rents/Results_v6/hMetis/PPIs_', num2str(cutoff), '_shMetis.mat'];
save(save_as_file)