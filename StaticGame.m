classdef StaticGame < handle
    %STATICGAME This class defines an amusement park setting.
    %   The rewards are static distributions
    
    % Member variables to define the amusement park problem
    properties
        nSites      %Number of park sites
        siteDist    %Matrix of Pairwise distances between sites
        m0          %Fixed distance from starting point to all sites
        means       %1-x-n CURRENT Mean satisfaction from ride
        sigmas      %1-x-n CURRENT Std. Deviations of rides
        lambdas     %1-x-n CURRENT Vector of Poisson parameters
        nRounds %Rounds to run game for
    end
    
    methods
        
        % Initializes game with parameters
        function init(self,nSites,siteDist,m0,means,sigmas,lambdas,nRounds)
            self.nSites = nSites;
            self.siteDist = siteDist;
            self.m0 = m0;
            self.means = means;
            self.sigmas = sigmas;
            self.lambdas = lambdas;
            self.nRounds = nRounds;
        end
            
        % Returns the reward for a single (state,action) pair
        % f,g,h > 0
        function reward = get_reward(site,next_site,f,g,h)
            dist = self.siteDist(site,next_site);
            waitTime = poissrnd(self.lambdas(next_site));
            satisf = normrnd(self.means(next_site),self.sigmas(next_site));
            
            % Signs reflect reward
            reward = -f*dist - g*waitTime + h*satisf;
        end
        
        % Returns vector of rewards for all actions from a given state
        function rewards = get_all_rewards(site,f,g,h)
            
            %TODO - need to discourage just taking same ride
            dists = self.siteDists(site,:);
            waitTimes = poissrnd(self.lambdas);
            satisfs = normrnd(self.means,self.sigmas);
            
            %Set reward for current site to 0;
            satisfs(site) = 0;
            
            rewards = -f*dists - g*waitTimes + h*satisfs;
        end
        
        %Reward for moving from initial state
        function init_reward = get_init_reward(next_site,f,g,h)
            waitTime = poissrnd(self.lambdas(next_site));
            satisf = normrnd(self.means(next_site),self.sigmas(next_site));
            
            init_reward = -f*self.m0 - g*waitTime + h*satisf;
        end
        
        %Reward for moving from init state to all
        function init_rewards = get_init_rewards(f,g,h)
            waitTimes = poissrnd(self.lambdas);
            satisfs = normrnd(self.means,self.sigmas);
            
            satisfs(site) = 0;
            
            init_rewards = -f*self.m0*ones(size(self.means)) -g*waitTimes + h*satisfs;
        end
        
        
    end
    
end

