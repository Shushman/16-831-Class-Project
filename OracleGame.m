classdef OracleGame < handle
    %ORACLEGAME This is the amusement park game for the oracle (full DP)
    %   Detailed explanation goes here
    
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
        % Don't need sigmas as no variance in reward
        function init(self,nSites,siteDist,m0,means,lambdas,nRounds)
            self.nSites = nSites;
            self.siteDist = siteDist;
            self.m0 = m0;
            self.means = means;
            self.lambdas = lambdas;
            self.nRounds = nRounds;
        end
        
        % Returns vector of rewards for all actions from a given state
        function rewards = get_all_rewards(self,site,f,g,h)
            
            %TODO - need to discourage just taking same ride
            dists = self.siteDist(site,:);
            waitTimes = self.lambdas;
            satisfs = self.means;
            
            %Set reward for current site to 0;
            satisfs(site) = 0;
            
            rewards = -f*dists - g*waitTimes + h*satisfs;
        end
        
        
        %Reward for moving from init state to all
        function init_rewards = get_init_rewards(self,f,g,h)
            waitTimes = self.lambdas;
            satisfs = self.means;
            
            init_rewards = -f*self.m0*ones(size(self.means)) -g*waitTimes + h*satisfs;
        end
        
    end
    
end

