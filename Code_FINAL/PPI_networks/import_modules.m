function modules = import_modules(filename)
%% Makes a matrix of modules with GO Terms in column 1
%IMPORTFILE Import numeric data from a text file as column vectors.
%   [GOID,ANNOTATED_GENES] = IMPORTFILE(FILENAME) Reads data from text file
%   FILENAME for the default selection.
%
%   [GOID,ANNOTATED_GENES] = IMPORTFILE(FILENAME, STARTROW, ENDROW) Reads
%   data from rows STARTROW through ENDROW of text file FILENAME.
%
% Example:
%   [GOID,ANNOTATED_GENES] = importfile('AG10803-DS12374_gotermfinder_tab.txt',14, 706);
%
%    See also TEXTSCAN.

% Auto-generated by MATLAB on 2016/06/25 00:43:37

%% Initialize variables.
delimiter = '\t';
if nargin<=2
    startRow = 13;
    endRow = inf;
end

%% Format string for each line of text:
%   column1: text (%s)
%	column11: text (%s)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%*s%*s%*s%*s%*s%*s%*s%*s%*s%s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
textscan(fileID, '%[^\n\r]', startRow(1)-1, 'WhiteSpace', '', 'ReturnOnError', false);
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'ReturnOnError', false);
for block=2:length(startRow)
    frewind(fileID);
    textscan(fileID, '%[^\n\r]', startRow(block)-1, 'WhiteSpace', '', 'ReturnOnError', false);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'ReturnOnError', false);
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Close the text file.
fclose(fileID);

%% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.


%% Allocate imported array to column variable names
ind = strncmpi('GO:', dataArray{:,1}, 3);
check = dataArray{:,1};
GOID = upper(check(ind));
check = dataArray{:,2};
ANNOTATED_GENES = check(ind);
for t = 1:length(ANNOTATED_GENES)
    temp = strsplit(ANNOTATED_GENES{t},',');
    for g = 1:length(temp)
        GOID{t,1+g} = upper(temp(g));
    end
end

modules = GOID;
end