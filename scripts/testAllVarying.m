clc; clear;

addpath ../policies
addpath ../games
addpath ../data
addpath ../
draw = 0;

%% Game parameters
[map, game] = varyingPark('uniform', 12, 60);

%% nRounds or other parameters can be changed here
nRounds = 100;

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
    if draw
        map.draw(prevsite, site, game, 'UCB');
    end
    prevsite = site;
end


% EXP3 Policy
game.reset();
exp3Policy = EXP3DPPolicy(game);
agent = Agent(exp3Policy, game);
EXP3sites = zeros(nRounds,1);
EXP3rewards = zeros(nRounds,1);
prevsite = 0;
for i = 1:nRounds
    [reward, site, ~, satisf, waitTime] = agent.ride();
    EXP3sites(i) = site;
    EXP3rewards(i) = reward;
    exp3Policy.updatePolicy(prevsite, site, reward);
    if draw
        map.draw(prevsite, site, game, 'EXP3');
    end
    prevsite = site;
end


%% TDPolicy
game.reset();
td_para.H       = nRounds;
td_para.n       = 1; 
td_para.epsilon = [1 1 1];%[1 0.2 0.10];
td_para.switchT = 0.5;
td_para.gamma   = 0.3;
td_para.alpha   = 0.9;
td_para.lambda  = 0.6;
TDpolicy = TDPolicy(game,td_para);

% for online learning, training function only do some initialization
TDpolicy.training(1,true); 
disp(TDpolicy.P);

% test the TDpolicy
game.reset();
agent     = Agent(TDpolicy, game);
TDsites   = zeros(nRounds,1);
TDrewards = zeros(nRounds,1);
for i = 1:nRounds
    s              = agent.site;
    [reward, site] = agent.ride();
    TDpolicy.updatePolicy(reward,site,s);
    TDsites(i)     = site;
    TDrewards(i)   = reward;
end



figure(1)
subplot(1,2,1)
plot(1:nRounds, cumsum(UCBrewards),'k+',...
     1:nRounds, cumsum(TDrewards),'bp',...
     1:nRounds, cumsum(EXP3rewards), 'g*');
xlabel('Rounds');
ylabel('Cumulative Rewards')
title('Comparison of UCB, TD, EXP3')
legend('UCB','TD','EXP3');

subplot(1,2,2)
plot(1:nRounds, UCBsites(1:nRounds), 'k+',...
     1:nRounds, TDsites(1:nRounds), 'bp',...
     1:nRounds, EXP3sites(1:nRounds), 'g*');
 xlabel('Rounds');
ylabel('Action taken at each timestep')
title('Comparison of UCB, TD, EXP')
legend('UCB','TD','EXP3');