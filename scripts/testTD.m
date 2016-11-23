clc; clear;

addpath ../policies
addpath ../games
addpath ../

%% Game parameters
nSites = 4;
% siteDist = ones(4,4) - eye(4);
% m0 = 0;
% means = [10, 20, 30, 40];
% lambdas = [20,5,5,30];
% nRounds = 500;
% f = 0; g = 0; h = 1;
siteDist = [0 5 100 100; 50 0 10 100; 55 60 0 5; 10 130 65 0];
m0 = 20;
means = [50,20,30,50];
lambdas = [20,5,5,30];
nRounds = 500;
f = 1; g = 1; h = 1.5;


% Game
N = 50;
result = zeros(N,1);
for iter=1:N
	game = ConstantGame(nSites,siteDist,m0,means,lambdas,nRounds,f,g,h);

	%% Generate object 
	policy = TDPolicy(game);
	% train the policy
	policy.training(1);
	% disp(policy.P);

	% test the policy
	game.round = 0;
	agent = Agent(policy, game);
	sites = zeros(nRounds+10,1);
	rewards = zeros(nRounds+10,1);
	for i = 1:nRounds + 10
	    [reward, site] = agent.ride();
	    sites(i) = site;
	    rewards(i) = reward;
	end
	disp(sum(rewards));
	if sum(rewards) > 17000 
		result(iter) = 1;
	end

end
disp(sum(result)/N);
return;
figure(1);clf(1);hold on;
subplot(2,1,1);
plot(1:nRounds + 10, cumsum(rewards), '.-')
xlabel('rounds')
ylabel('cumulative rewards')
subplot(2,1,2);
plot(1:nRounds + 10, sites,'o');
