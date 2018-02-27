function out = keep_revigo(modules, significant_go_terms)

[data, indecesA, indecesB] = intersect(modules(:,1), significant_go_terms);

out = modules(indecesA,:);

end