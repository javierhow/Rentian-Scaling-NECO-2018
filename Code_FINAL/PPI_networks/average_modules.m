function [average_x, average_y] = average_modules(x,y)
average_x = unique(x);
average_y = zeros(size(y));

for t = 1:length(average_x)
    smallest = average_x(t);
    index = find(smallest == x);
    average_y(t) = mean(y(index));
end

index = find(average_x ~= 0);
average_x = average_x(index);
average_y = average_y(index);
end