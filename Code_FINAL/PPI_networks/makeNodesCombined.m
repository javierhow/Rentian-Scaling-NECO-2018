function nodesCombined = makeNodesCombined(modules)
import java.util.*;
import java.lang.*;
%% Make modules useful
nodesCombined = cell(size(modules, 1), 1);
for r = 1:size(modules,1)
    sameRow = java.util.HashSet;
    c = 2;
    j = 1;
    while c ~= size(modules,2) + 1 && ~isempty(modules{r,c})
        sameRow.add(strtrim(modules{r,c}));
        j = j+1;
        c = c + 1;
    end
    nodesCombined(r) = sameRow.clone();
end
end