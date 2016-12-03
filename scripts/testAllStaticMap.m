clc; clear;

addpath ../policies
addpath ../games
addpath ../data
addpath ../

%% Game parameters
load('map1.mat');

%% nRounds or other parameters can be changed here
nRounds = 100;
% f = 1.5;

%% Generate object 
sigmas = diag(sigmas)';
game = StaticGame(nSites,siteDist,m0,means,sigmas,lambdas,nRounds,f,g,h);

% FullDP policy
DPpolicy = valueIteration(game,f,g,h);
agent = Agent(DPpolicy, game);
game.reset();
DPsites = zeros(nRounds,1);
DPrewards = zeros(nRounds,1);
for i = 1:nRounds
    [reward, site] = agent.ride();
    DPsites(i) = site;
    DPrewards(i) = reward;
end

% UCB Policy
game.reset();
ucbPolicy = UCBPolicy(game);
agent = Agent(ucbPolicy, game);
UCBsites = zeros(nRounds,1);
UCBrewards = zeros(nRounds,1);
prevsite = 0;
for i = 1:nRounds
    [reward, site, ~, satisf, waitTime] = agent.ride();
    UCBsites(i) = site;
    UCBrewards(i) = reward;
    ucbPolicy.updatePolicy(prevsite, site, satisf, waitTime);
    prevsite = site;
end



%% TDPolicy
game.reset();
TDpolicy = TDPolicy(game);

% train the policy
TDpolicy.training(1);
disp(TDpolicy.P);

% test the policy
game.reset();
agent = Agent(TDpolicy, game);
TDsites = zeros(nRounds,1);
TDrewards = zeros(nRounds,1);
for i = 1:nRounds 
    [reward, site] = agent.ride();
    TDsites(i) = site;
    TDrewards(i) = reward;
end



figure(1)
subplot(1,2,1)
plot(1:nRounds, cumsum(DPrewards), 'ro',...
     1:nRounds, cumsum(UCBrewards),'k+',...
     1:nRounds, cumsum(TDrewards),'bp');
xlabel('Rounds');
ylabel('Cumulative Rewards')
title('Comparison of DP, UCB, TD')
legend('DP','UCB','TD');

subplot(1,2,2)
plot(1:nRounds, DPsites, 'ro',...
     1:nRounds, UCBsites, 'k+',...
     1:nRounds, TDsites, 'bp');
 xlabel('Rounds');
ylabel('Action taken at each timestep')
title('Comparison of DP, UCB, TD')
legend('DP','UCB','TD');