clear;clc;clf;close all;

nSites = 60;
nparts = 6;

assert(mod(nSites,nparts)==0);

rng(6);

XMAX = 10;
YMAX = 10;
GRIDS = XMAX*YMAX;
[X,Y] = meshgrid(1:XMAX,1:YMAX);
X = X(:);
Y = Y(:);
index = randperm(GRIDS,nparts);
X = X(index);
Y = Y(index);
Cntr = [X';Y'];
Std = rand(1,nparts)/2+0.5;

X = [];

n = round(nSites/nparts);
for i = 1:nparts
    X = [X randn(2,n)*Std(i)+repmat(Cntr(:,i),1,n)];
end

siteDist = pdist2(X',X');
means = randi(40,1,nSites);
sigmas = randi(1,nSites)*5;
lambdas = randi(20,1,nSites);
nRounds = 150;
m0 = 5;
f = 1; g = 1; h = 1;

save('varyingPark.mat','nSites','siteDist','m0','means','sigmas','lambdas','nRounds','f','g','h');
cmap = colormap(hot);

figure(1);
colormap(cmap);
title('Satisfaction Means');
hold on;
figure(2);
colormap(cmap);
title('WaitTime Lambdas');
hold on;

for i = 1:nSites
    figure(1);
    scatter(X(1,i),X(2,i),'MarkerEdgeColor',cmap(round(means(i)/40*64),:));
    figure(2);
    round(lambdas(i)/20*64)
    scatter(X(1,i),X(2,i),'MarkerEdgeColor',cmap(round(lambdas(i)/20*64),:));
end