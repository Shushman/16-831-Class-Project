clear;clc;clf;close all;

% number of sites
nSites = 60;
nparts = 6;

assert(mod(nSites,nparts)==0);

rng(6);

% X, Y location of rides
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

% parameters for functions
T = 60+rand(1,nSites)*40;
M = 3*rand(1,nSites);
offset = 10+randi(10,1,nSites);
phase = rand(1,nSites)*2*pi;

% parameters
siteDist = pdist2(X',X');
meanss = randi(40,1,nSites);
sigmass = rand(1,nSites)*3;
fctnsw = cell(1,nSites);
for i = 1:nSites
    fctnsw{i}=@(x) offset(i)+M(i)*sin(2*pi/T(i)*x+phase(i));
end
sigmasw = rand(1,nSites)*2;
nRounds = 150;
m0 = 5;
f = 1; g = 1; h = 1;

% save data
save('varyingPark.mat','nSites','siteDist','m0','meanss','sigmass','fctnsw','sigmasw','nRounds','f','g','h');
% 
% hold on;
% for i = 1:nSites
%     plot(fctnsw{i}(1:nRounds));
% end
% cmap = colormap(hot);
% 
% figure(1);
% colormap(cmap);
% title('Satisfaction Means');
% hold on;
% figure(2);
% colormap(cmap);
% title('WaitTime Lambdas');
% hold on;
% 
% for i = 1:nSites
%     figure(1);
%     scatter(X(1,i),X(2,i),'MarkerEdgeColor',cmap(round(means(i)/40*64),:));
%     figure(2);
%     round(lambdas(i)/20*64)
%     scatter(X(1,i),X(2,i),'MarkerEdgeColor',cmap(round(lambdas(i)/20*64),:));
% end