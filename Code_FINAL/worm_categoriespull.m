% Process C. elegans network based on each neuron's function
%% Import network
[~, ~, raw] = xlsread('/home/jhow/Documents/OfficialRents/DataSets/Worm/NeuronConnect.xls','NeuronConnect.csv');

raw = raw(2:end,:);
raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};
cellVectors = raw(:,[1,2,3]);
raw = raw(:,4);

% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw); % Find non-numeric cells
raw(R) = {NaN}; % Replace non-numeric cells

% Create output variable
data = reshape([raw{:}],size(raw));

% Allocate imported array to column variable names
Neuron1 = cellVectors(:,1);
Neuron2 = cellVectors(:,2);
Type1 = cellVectors(:,3);
Nbr = data(:,1);

wormnetwork = [Neuron1 Neuron2];

% Clear temporary variables
clearvars data raw cellVectors R Neuron1 Neuron2

%% Import the categories
[~, ~, raw] = xlsread('/Users/How/Documents/Saket Navlakha/Official Rents/Data sets/Worm/worm_neuroncategories.xlsx','Sheet1');
%[~, ~, raw] = xlsread('/home/jhow/Documents/OfficialRents/DataSets/Worm/worm_neuroncategories.xlsx','Sheet1');
raw = raw(:,1:5);
raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};
cellVectors = raw(:,[1,2,3,4,5]);

% Allocate imported array to column variable names
Neuron_names = cellVectors(:,1);
Neuron_categories(:,1) = cellVectors(:,2);
Neuron_categories(:,2) = cellVectors(:,3);
Neuron_categories(:,3) = cellVectors(:,4);
Neuron_categories(:,4) = cellVectors(:,5);

% Clear temporary variables
clearvars data raw cellVectors;

%% Bring modules together
% Some of this is new as of 8.25.16

% This was missing one module: new
%wormmodules = cell(length(unique(Neuron_categories(:,1))), 1);
wormmodules = cell(length(unique(Neuron_categories(:,:))), 1);
wormmodules(:,1) = unique(Neuron_categories(:,:));
% Because the first one is empty (''): new
wormmodules(1,:) = [];
for t =1:length(wormmodules)
    MOI = char(wormmodules(t));       % ModuleOfInterest
    index1 = find(strcmp(MOI, Neuron_categories(:,1)));     % check for it in each column of cats
    index2 = find(strcmp(MOI, Neuron_categories(:,2)));
    index3 = find(strcmp(MOI, Neuron_categories(:,3)));
    index4 = find(strcmp(MOI, Neuron_categories(:,4)));
    indexA = union(index1, index2);                         % combine the list of indeces
    indexB = union(index3, index4);
    index = union(indexA, indexB);
    NOI = Neuron_names(index);                              % nodes in that module
    
    for r=1:length(NOI)
        wormmodules(t,r+1) = NOI(r);
    end
end

% The below was dumb
%{
tempModules = wormmodules;
sizeofmods = size(tempModules);
wormmodules = cell(sizeofmods(1), sizeofmods(2) + 1);
wormmodules(:,1) = unique(Neuron_categories(:,1));
wormmodules(:,2:end) = tempModules;
%}

%% Process some more
wormmodules = cellfun(@char, wormmodules, 'UniformOutput', false);

newNetwork = processNetwork(wormnetwork, wormmodules);        % if not in modules, remove from network
newNetwork = strtrim(newNetwork);
newModules = processModules(newNetwork, wormmodules);        % if not in network, remove from modules; pointless to do this first
newModules = strtrim(newModules);
newModules = cellfun(@char, newModules, 'UniformOutput', false);


%% Rest
%[Empirical_rent, randomMod_rent, randomEdge_rent, randomModSingle_rent, h, p] = processRentExponent(newModules, newNetwork);
[Empirical_rent, b2, R2, randomMod_rent, randomEdge_rent, ...
    random_mod_edge_rent, h, p, x, y, randModx, randMody, ...
    randEdgex, randEdgey, randBothx, randBothy] ...
    = processRentExponent_v3(newModules, newNetwork);
delete(poolobj);

clear t

numNodes = length(unique(newNetwork(:)));
freeNet = removeRedundantNet(newNetwork);
numEdges = size(freeNet,1);
numModules = size(newModules,1);

save('/home/jhow/Documents/OfficialRents/Results/Worm/worm_categoriesresults.mat');