classdef ConstantGame < Game
    %CONSTANTGAME Summary of this class goes here
    %   Detailed explanation goes here
    
    % Member variables to define the amusement park problem
    properties
        nSites      %Number of park sites
        siteDist    %Matrix of Pairwise distances between sites
        m0          %Fixed distance from starting point to all sites
        means       %1-x-n CURRENT Mean satisfaction from ride
        nRounds     %Rounds to run game for
        round       % current round
        lambdas     % waittime
        weightDist           % weight on distance
        weightWait          % weight on wait time
        weightRide           % weight on ride satisfaction
    end
    
    methods
        
        % Initializes game with parameters
        function self = ConstantGame(nSites,siteDist,m0,means,lambdas,nRounds,f,g,h)
            self.nSites = nSites;
            self.siteDist = siteDist;
            self.m0 = m0;
            self.means = means;
            self.lambdas = lambdas;
            self.nRounds = nRounds;
            self.weightDist = f;
            self.weightWait = g;
            self.weightRide = h;
            self.round = 0;     

        end
        
        function reset(self)
            self.round = 0;     
        end
        
        function reward = get_reward(self, site, next_site)
            [dist, waitTime, satisf] = get_eltwise_reward(self, site, next_site);
            reward = -self.weightDist*dist - self.weightWait*waitTime + self.weightRide*satisf;
        end
        
        function rewards = get_all_rewards(self, site)
            [dists, waitTimes, satisfs] = get_eltwise_rewards(self, site);
            rewards = -self.weightDist*dists - self.weightWait*waitTimes + self.weightRide*satisfs;
            rewards = rewards';
        end
        
        function [dist, waitTime, satisf] = get_eltwise_reward(self, site, next_site)
            self.round = self.round + 1;
            
            if site < 1
                waitTime = self.lambdas(next_site);
                satisf = self.means(next_site);
                dist = self.m0;
                return
            end
            
            dist = self.siteDist(site,next_site);
            waitTime = self.lambdas(next_site);
            
            % Set reward for current site to 0;
            if site == next_site
                satisf = 0;
            else
                satisf = self.means(next_site);
            end
        end
        
        function [dists, waitTimes, satisfs] = get_eltwise_rewards(self, site)
            self.round = self.round + 1;             
            if site < 1
                waitTimes = self.lambdas;
                satisfs = self.means;
                dists = self.m0*ones(self.nSites, 1);
                return
            end
            
            dists = self.siteDist(site,:)';
            waitTimes = self.lambdas;
            satisfs = self.means;
            
            %Set reward for current site to 0;
            satisfs(site) = 0;
        end
        
    end
end

