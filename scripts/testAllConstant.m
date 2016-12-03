clc; clear;

addpath ../policies
addpath ../games
addpath ../

%% Game parameters
nSites = 4;
siteDist = [0 5 100 100; 50 0 10 100; 55 60 0 5; 10 130 65 0];
m0 = 20;
means = [50,20,30,50]';
lambdas = [20,5,5,30]';
nRounds = 500;
f = 1; g = 1; h = 1.5;

%% Generate object 
game = ConstantGame(nSites,siteDist,m0,means,lambdas,nRounds,f,g,h);


% FullDP policy
DPpolicy = valueIteration(game,f,g,h);
agent = Agent(DPpolicy, game);
game.reset()
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
nRounds = 50;
plot(1:nRounds, DPsites(1:50), 'ro',...
     1:nRounds, UCBsites(1:50), 'k+',...
     1:nRounds, TDsites(1:50), 'bp');
 xlabel('First 50 Rounds');
ylabel('Action taken at each timestep')
title('Comparison of DP, UCB, TD')
legend('DP','UCB','TD');
 