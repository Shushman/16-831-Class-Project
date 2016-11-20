clc; clear;

%% Game parameters
% nSites = 5;
% distTri = 50*rand(nSites,nSites);
% siteDist = triu(distTri,1) + triu(distTri,1)';
% m0 = 20;
% means = 30+70*rand(1,nSites);
% lambdas = 50*rand(1,nSites);

nSites = 4;
siteDist = [0 5 100 100; 50 0 10 100; 55 60 0 5; 10 130 65 0];
%siteDist = distTri + distTri';
m0 = 20;
means = [50,20,30,50];
lambdas = [20,5,5,30];
nRounds = 500;
f = 1; g = 1; h = 1.5;

%% Generate object 
og = OracleGame();
og.init(nSites,siteDist,m0,means,lambdas,nRounds);
[policy,value,firstSite] = valueIterationOracleGame(og,f,g,h);