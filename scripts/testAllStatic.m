clc; clear;

addpath ../policies
addpath ../games
addpath ../data
addpath ../

%% Game parameters
nSites = 10;
map = Map(10, 100, 1, 'uniform');
means = clamp(rand(1,nSites));
sigmas = 0.1*clamp(rand(1,nSites));
lambdas = 0.1*clamp(rand(1,nSites));

%% nRounds or other parameters can be changed here
nRounds = 100;
w = [1 1 1];
w = w/sum(w);

draw = 0;

%% Generate object 
game = StaticGame(map, means,sigmas,lambdas,nRounds,w(1),w(2),w(3));

% FullDP policy
DPpolicy = valueIteration(game);
agent = Agent(DPpolicy, game);
game.reset();
DPsites = zeros(nRounds,1);
DPrewards = zeros(nRounds,1);
prevsite = 0;
for i = 1:nRounds
    [reward, site] = agent.ride();
    DPsites(i) = site;
    DPrewards(i) = reward;
    if draw
        map.draw(prevsite, site, game, 'DP');
    end
    prevsite = site;

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
td_para.epsilon = [1 0.2 0.05];%[1 0.2 0.10];
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
    prevsite       = agent.site;
    [reward, site] = agent.ride();
    TDpolicy.updatePolicy(reward,site,prevsite);
    TDsites(i)     = site;
    TDrewards(i)   = reward;
    if draw
        map.draw(prevsite, site, game, 'EXP3');
    end
end

% Random Policy
game.reset();
RNDPolicy = RandomPolicy(game);
agent = Agent(RNDPolicy, game);
RNDsites = zeros(nRounds,1);
RNDrewards = zeros(nRounds,1);
prevsite = 0;
for i = 1:nRounds
    [reward, site, ~, satisf, waitTime] = agent.ride();
    RNDsites(i) = site;
    RNDrewards(i) = reward;
    prevsite = site;
    % if draw
    %     map.draw(prevsite, site, game, 'RND');
    % end
end

allRewards = [sum(DPrewards) sum(UCBrewards) sum(TDrewards) sum(EXP3rewards) sum(RNDrewards)];
names = {'DP','UCB','TD','EXP3','RND'};
[~,idx] = sort(allRewards);
disp(names(idx));
disp(allRewards(idx));

figure(1)
subplot(1,2,1)
plot(1:nRounds, cumsum(DPrewards), 'ro',...
     1:nRounds, cumsum(UCBrewards),'k+',...
     1:nRounds, cumsum(TDrewards),'bp',...
     1:nRounds, cumsum(EXP3rewards), 'g*');
hold on;plot(1:nRounds, cumsum(RNDrewards), 'r.','markersize',10);hold off
xlabel('Rounds');
ylabel('Cumulative Rewards')
title('Comparison of DP, UCB, TD,RND')
legend('DP','UCB','TD','EXP3','RND');

subplot(1,2,2)
plot(1:nRounds, DPsites(1:nRounds), 'ro',...
     1:nRounds, UCBsites(1:nRounds), 'k+',...
     1:nRounds, TDsites(1:nRounds), 'bp',...
     1:nRounds, EXP3sites(1:nRounds), 'g*');
hold on; plot(1:nRounds, RNDsites(1:nRounds), 'r.','markersize',10); hold off
xlabel('Rounds');
ylabel('Action taken at each timestep')
title('Comparison of DP, UCB, TD, RND')
legend('DP','UCB','TD','EXP3','RND');