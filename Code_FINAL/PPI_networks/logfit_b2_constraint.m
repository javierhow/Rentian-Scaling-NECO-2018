function [out R2] = logfit_b2_constraint(x,y,b2)
%% Adapted from logfit.m
new_x = x;
new_y = y;
logX=log10(new_x); logY=log10(new_y);

% Modification from original
mask = logY<=b2;
logY = logY(~mask);
logX = logX(~mask);
new_x = new_x(~mask);
new_y = new_y(~mask);
% Modification ends

% Find slope for data you want, using y-intercept from empirical data
temp_Rent = mean((logY-b2)./logX);


% The below can gives a Rent exponent larger than 1, when I use all values
% (i.e. including values of X that are equal to 1, which is what produce
% Inf as a Rent value, otherwise). Instead, I use x values greater than 1,
% and use the above line to calculate Rent's Exponent
%temp_Rent = (new_y - 10^b2)./new_x;
%temp_Rent = mean(temp_Rent);
%temp_Rent = log10(temp_Rent);

ftir = 20;

range = [0.1 max(new_x)];
logRange=log10(range);
totRange=diff(logRange)+10*eps;                                             % In case all zeros...
logRange = [logRange(1)-totRange/ftir, logRange(2)+totRange/ftir];
ex = linspace(logRange(1),logRange(2),100);

%% Do the linear fitting and evaluating
p = [temp_Rent b2];
yy = polyval(p,ex);
%ey=polyval(p,logX); % the estimate of the 'y' value for each point.

ey = b2*ex.^temp_Rent;
%ey = random_mod_Rent*ex+b2;

%plot(ex,ey)

yy=10.^yy;
ex=10.^ex;
ey=10.^ey;
%plot(ex,ey)
plot(ex,yy)
hold on
scatter(new_x, new_y)

out = temp_Rent;

%% Calculate MSE and R2
estY=polyval(p,logX);
estY=10.^estY; logY=10.^logY;
% Note that this is done after the data re-scaling is finished.
MSE = mean((logY-estY).^2); % mean squared error.

%     COVyhaty    = cov(estY,y); % = cov(estimated values, experimental values)
%     R2        = (COVyhaty(2).^2) ./(var(estY).*var(y));
%     
y2fit = new_y;
tmp = corrcoef(estY,y2fit).^2;
R2 = tmp(2);

end
