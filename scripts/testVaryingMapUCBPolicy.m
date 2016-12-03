clc; clear;

addpath ../policies
addpath ../games
addpath ../data
addpath ../

%% Game parameters
load('varyingPark.mat');

%% nRounds or other parameters can be changed here
nRounds = 500;
% f = 2;

%% Generate object 
game = VaryingGame(nSites,siteDist,m0,meanss,sigmass,fctnsw,sigmasw,nRounds,f,g,h);
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

