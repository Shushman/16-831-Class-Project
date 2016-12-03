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

policy = valueIteration(game,f,g,h);

% run policy
agent = Agent(policy, game);
sites = zeros(nRounds,1);
rewards = zeros(nRounds,1);
for i = 1:nRounds
    [reward, site, ~, satisf, waitTime] = agent.ride();
    sites(i) = site;
    rewards(i) = reward;
end

plot(1:nRounds, cumsum(rewards), 'o-')
xlabel('rounds')
ylabel('cumulative rewards')

figure(2);
plot(1:nRounds, sites,'o')

