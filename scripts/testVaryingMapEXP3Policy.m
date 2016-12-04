clc; clear;

addpath ../policies
addpath ../games
addpath ../data
addpath ../

%% Game parameters
load('varyingPark.mat');
meanss = meanss / max(meanss);

%% nRounds or other parameters can be changed here
nRounds = 10000;
f = 0.3;
g = 0.1;
h = 0.5;

%% Generate object 
figure(1);clf;
for j=1:10
normalize=1;
game = VaryingGame(nSites,siteDist,m0,meanss,sigmass,fctnsw,sigmasw,nRounds,f,g,h,normalize);
policy = EXP3DPCompPolicy(game);
agent = Agent(policy, game);
sites = zeros(nRounds,1);
rewards = zeros(nRounds,1);
prevsite = 0;
for i = 1:nRounds
    [reward, site, ~, satisf, waitTime] = agent.ride();
    sites(i) = site;
    rewards(i) = reward;
    policy.updatePolicy(prevsite,site,satisf, waitTime);
    prevsite = site;
end
subplot(1,2,1);hold on;
plot(1:nRounds, cumsum(rewards), 'o-')
xlabel('rounds')
ylabel('cumulative rewards')

subplot(1,2,2);hold on;
plot(1:nRounds, sites,'o','LineWidth',3);
xlabel('Rounds');
ylabel('Actions taken');
end;
hold off;
% policy.drawUpperBounds();
% figure(2);
% plot(1:nRounds, sites,'o')
