clc; clear;

addpath ../policies
addpath ../games
addpath ../

%% Game parameters
nSites = 4;
siteDist = ones(4,4) - eye(4);
m0 = 0;
means = [10, 20, 30, 40];
means = means / max(means);
lambdas = [20,5,5,30];
lambdas = lambdas / max(lambdas);

nRounds = 50;
f = 0; g = 0; h = 1;

%% Generate object 
normalize = 1;
game = ConstantGame(nSites,siteDist,m0,means,lambdas,nRounds,f,g,h,normalize);
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

figure(1);
subplot(1,2,1);
plot(1:nRounds, cumsum(rewards), 'o-','LineWidth',3);
xlabel('Rounds')
ylabel('Cumulative Rewards')

subplot(1,2,2);
plot(1:nRounds, sites,'o','LineWidth',3);
xlabel('Rounds');
ylabel('Actions taken');

policy.drawUpperBounds();

