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
game = ConstantGame(nSites,siteDist,m0,means,lambdas,nRounds,f,g,h);
policy = UCBPolicy(game);
agent = Agent(policy, game);
sites = zeros(nRounds,1);
rewards = zeros(nRounds,1);
prevsite = 0;
for i = 1:nRounds
    [reward, site, ~, satisf, waitTime] = agent.ride();
    sites(i) = site;
    rewards(i) = reward;
    policy.updatePolicy(prevsite, site, satisf, waitTime);
    prevsite = site;
end
figure(1)
plot(1:nRounds, cumsum(rewards), 'o-')
xlabel('rounds')
ylabel('cumulative rewards')

figure(2)
plot(1:nRounds, sites,'o','LineWidth',3);
xlabel('Rounds');
ylabel('Actions taken');
% policy.drawUpperBounds();
% figure(2);
% plot(1:nRounds, sites,'o')

