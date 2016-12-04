classdef TDPolicy < Policy
    %POLICY This is an abstract class defining a policy.
    properties
        game
        nSites
        P  % Policy of states
        P0 % Policy of initial position
        td_para % parameters for TD
        online % online learning or not
        SV % variables used by SARSA
    end

    methods
    	% Initializes game with parameters
    	function self = TDPolicy(game, para)
    		self.game = game;
    	    self.nSites = game.nSites;
    	    self.P = zeros(self.nSites,1);
    	    self.P0 = 0;
    	    self.td_para = para;
    	    self.online = false;
    	end

    	% training
        function Q = training(self, nEpisodes, online )
        	% fill in interface with SARSA algorithm
        	ns = self.nSites;
        	Q = cell(ns+1,1);
        	for i = 1:ns+1
        		Q{i} = rand(ns,1);
        	end
        	A = ns*ones(ns+1,1);
        	s0 = 1;

        	fun       = @(site, action) deal(action+1, self.game.get_reward(site-1,action));
        	% paraTrain: struct of parameters for training process
        	% 	H: length of each episode
        	% 	n: number of episodes
        	% 	epsilon: parameter in the epsilon-greedy algorithm. (0~1) 
        	% 		0 is greedy, 1 is random.
        	% 	gamma: eligibility tree discount factor
        	% 	alpha: Q update step size, 0< alpha <= 1
        	% 	lambda: SARSA(lambda)
            self.online = online;
            if ~online
                for epid = 1:nEpisodes
                    [P_, Q] = SARSA(s0, Q, ns+1, A, fun, self.td_para);
                end
                
                self.P0 = P_(1);
                self.P = P_(2:end);
            else
                % only do initialization
                sv.Q  = Q;
                sv.ns = ns+1;
                sv.A  = A;
                sv.T1 = ceil(self.td_para.H*self.td_para.switchT);
                sv.Z  = cell(sv.ns,1);
                for is = 1:sv.ns
                    sv.Z{is} = zeros(sv.A(is),1);
                end
				sv.t    = 1;
				sv.anew = 1;
				self.SV = sv;
            end
        end 

        % Choose next site 
        function nextsite = decision(self, site, round_)
        	if ~self.online
        		if round_ == 0
        			nextsite = self.P0;
        		else
        			nextsite = self.P(site);
        		end
        	else
        		nextsite = self.SV.anew;
        	end
        end % end function

		% online learning
        function updatePolicy(self, reward,snew,s)
            snew = snew + 1; s = s + 1;
        	sv = self.SV;
        	if sv.t < sv.T1
        		epsilon = ( (sv.T1-sv.t)*self.td_para.epsilon(1) + sv.t*self.td_para.epsilon(2) )/sv.T1;
        	else
        		epsilon = self.td_para.epsilon(3);
        	end
        	a = sv.anew;
        	anew  = greedy_epsilon(sv.Q{snew}, epsilon);
        	delta = reward + self.td_para.gamma*sv.Q{snew}(anew) - sv.Q{s}(a);
        	% update eligibility tree
        	sv.Z{s}(a)        = sv.Z{s}(a) + 1;
        	for is = 1:sv.ns
        		for ia = 1:sv.A(is)
        			sv.Q{is}(ia) = sv.Q{is}(ia) + self.td_para.alpha*delta*sv.Z{is}(ia);
        			sv.Z{is}(ia) = self.td_para.gamma*self.td_para.lambda*sv.Z{is}(ia);
        		end
        	end
        	% update state action
			sv.anew = anew;
			sv.t    = sv.t + 1;
			self.SV = sv;
        end

    end
    
end


% input arguments:
	% s0: initial state ( index number )
	% Q: ns x 1 cell array. Q value of each state-action pair 
	% ns: number of states
	% A: ns x 1 array. number of actions at each state
	% f: dynamics of the MDP problem. state and action are index numbers
	% 	[snew, reward] = f(s, action)
	% 	snew = 0 denotes termination.
	% 	reward has to be non-negative
	% paraTrain: struct of parameters for training process
	% 	H: length of each episode
	% 	n: number of episodes
	% 	epsilon: parameter in the epsilon-greedy algorithm. (0~1) 
	% 		0 is greedy, 1 is random.
	% 	gamma: eligibility tree discount factor
	% 	alpha: Q update step size, 0< alpha <= 1
	% 	lambda: SARSA(lambda)
% output arguments:
	% P: policy. ns x 1 array. action at each state
	% Q: ns x 1 cell array. Q value of each state-action pair 
function [P, Q] = SARSA(s0, Q, ns, A, f, paraTrain)

% ------------------------------------------------------
% 		Initialization
% ------------------------------------------------------
% epsilon-greedy profile:
% 	T0 ~ T1: epsilon(1)~epsilon(2)
% 	after T1: epsilon(3)
T1 = ceil(paraTrain.H*paraTrain.switchT);

% ------------------------------------------------------
% 		Training
% ------------------------------------------------------
for epi = 1:paraTrain.n
	% initialize eligibility tree
	Z = cell(ns,1); 
	for is = 1:ns
		Z{is} = zeros(A(is),1);
	end

	% initialize state and action
	s = s0;
	a = 1;
	for t = 1:paraTrain.H
		% determine epsilon to use
		if t < T1
			epsilon = ( (T1-t)*paraTrain.epsilon(1) + t*paraTrain.epsilon(2) )/T1;
		else
			epsilon = paraTrain.epsilon(3);
		end

		[snew, reward] = f(s, a);
		if snew == 0
			% episode terminated
			continue;
		end
		anew           = greedy_epsilon(Q{snew}, epsilon);
		delta          = reward + paraTrain.gamma*Q{snew}(anew) - Q{s}(a);
		% update eligibility tree
		Z{s}(a)        = Z{s}(a) + 1;
		for is = 1:ns
			for ia = 1:A(is)
				Q{is}(ia) = Q{is}(ia) + paraTrain.alpha*delta*Z{is}(ia);
				Z{is}(ia) = paraTrain.gamma*paraTrain.lambda*Z{is}(ia);
			end
		end
		% update state action
		s = snew;
		a = anew;
	end
end

P = zeros(ns,1);
for i = 1:ns
	% greedy policy
	[~, P(i)] = max(Q{i});
end


end

% the epsilon-greedy policy
function a = greedy_epsilon(q, epsilon)
	n = length(q);
	if rand() < epsilon
		% random policy
		a = randi(n,1);
	else
		% greedy policy
		[~, a] = max(q);
	end
end

