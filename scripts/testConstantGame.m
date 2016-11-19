clc; clear;

addpath ../policies
addpath ../games
addpath ../

%% Game parameters
nSites = 4;
siteDist = ones(4,4) - eye(4);
m0 = 0;
means = [10, 20, 30, 40];
lambdas = [20,5,5,30];
nRounds = 10;
f = 0; g = 0; h = 1;

%% Generate object 
game = ConstantGame(nSites,siteDist,m0,means,lambdas,nRounds,f,g,h);
policy = RandomPolicy(game);
agent = Agent(policy, game);
sites = zeros(nRounds+10,1);
rewards = zeros(nRounds+10,1);
for i = 1:nRounds + 10
    [reward, site] = agent.ride();
    sites(i) = site;
    rewards(i) = reward;
end

plot(1:nRounds + 10, cumsum(rewards), 'o-')
xlabel('rounds')
ylabel('cumulative rewards')
