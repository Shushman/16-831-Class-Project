clc; clear;

addpath ../policies
addpath ../games
addpath ../data
addpath ../

%% Game parameters
nSites = 4;
map = Map(nSites, 100, 1, 'uniform');
means = [0.1, 0.3, 0.5, 0.8];
lambdas = [0.8, 0.5, 0.3, 0.1];
sigmas = clamp(rand(1,nSites));

%% nRounds or other parameters can be changed here
nRounds = 1000;
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
%     if draw
%         map.draw(prevsite, site, game, 'DP');
%     end
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
ucbPolicy.drawUpperBounds(game.means, game.lambdas);


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
td_para.gamma   = 1;
td_para.alpha   = 0.1;
td_para.lambda  = 0.1;
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
        map.draw(prevsite, site, game, 'TD');
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
end


% Hindsight Greedy Policy
game.reset();
greedyPolicy = HindsightGreedyPolicy(game);
greedysites = zeros(nRounds,1);
greedyrewards = zeros(nRounds,1);
prevsite = 0;
for i = 1:nRounds
    Rewards = game.get_reward(prevsite); % round +1
    [reward, site] = max(Rewards);

    greedysites(i) = site;
    greedyrewards(i) = reward;

    prevsite = site;
end


allRewards = [sum(DPrewards) sum(UCBrewards) sum(TDrewards) sum(EXP3rewards) sum(RNDrewards) sum(greedyrewards)];
names = {'DP','UCB','TD','EXP3','RND','Hindsight'};
[~,idx] = sort(allRewards);
disp(names(idx));
disp(allRewards(idx));



figure(1)

subplot(1,2,1)
plot(1:nRounds, cumsum(DPrewards), '-r',...
     1:nRounds, cumsum(UCBrewards),'-k',...
     1:nRounds, cumsum(TDrewards),'-b',...
     1:nRounds, cumsum(EXP3rewards), '-g',...
     1:nRounds, cumsum(RNDrewards), '-m',...
     1:nRounds, cumsum(greedyrewards), '-y','linewidth',2);
xlabel('Rounds', 'FontSize',20);
ylabel('Cumulative Rewards','FontSize',20)
legend('DP','UCB','TD','EXP3','RND','Hindsight');

subplot(1,2,2)
initRound = floor(nRounds/4*3);
plot(initRound:nRounds, DPsites(initRound:nRounds), 'ro',...
     initRound:nRounds, UCBsites(initRound:nRounds), 'k+',...
     initRound:nRounds, TDsites(initRound:nRounds), 'bp',...
     initRound:nRounds, EXP3sites(initRound:nRounds), 'g*',...
     initRound:nRounds, greedysites(initRound:nRounds), 'g*');
xlabel('Rounds', 'FontSize',20);
ylabel('Action', 'FontSize',20)
