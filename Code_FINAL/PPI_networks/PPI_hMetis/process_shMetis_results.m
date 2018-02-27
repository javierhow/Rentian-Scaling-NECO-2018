function [ave_num_nodes, ave_ext_degree, done] = process_shMetis_results(cmdout)
% Save average number of nodes and external degrees
split_cmdout = splitlines(cmdout);
ind = strfind(split_cmdout, 'Partition Sizes & External Degrees');
ind = find(~cellfun(@isempty,ind)) + 1;
if ~isempty(ind)
    useful_str = split_cmdout(ind);

    useful_str = strsplit(useful_str{:}, {'[', ']'});
    partOne_nodeCount = str2double(useful_str{1});
    partOne_extDegree = str2double(useful_str{2});
    partTwo_nodeCount = str2double(useful_str{3});
    partTwo_extDegree = str2double(useful_str{4});

    ave_num_nodes = mean([partOne_nodeCount partTwo_nodeCount]);
    ave_ext_degree = mean([partOne_extDegree partTwo_extDegree]);
    done = 0;
else
    done = 1;
    ave_num_nodes = nan;
    ave_ext_degree = nan;
end

end