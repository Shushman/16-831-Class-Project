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
        f           % weight on distance
        g           % weight on wait time
        h           % weight on ride satisfaction
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
            self.f = f;
            self.g = g;
            self.h = h;
            self.round = 0;
        end
        
        function reward = get_reward(self, site, next_site)
            [dist, waitTime, satisf] = get_eltwise_reward(self, site, next_site);
            reward = -self.f*dist - self.g*waitTime + self.h*satisf;
        end
        
        function rewards = get_all_rewards(self, site)
            [dists, waitTimes, satisfs] = get_eltwise_rewards(self, site);
            rewards = -self.f*dists - self.g*waitTimes + self.h*satisfs;
        end
        
        function [dist, waitTime, satisf] = get_eltwise_reward(self, site, next_site)
            self.round = self.round + 1;
            if self.round > self.nRounds
                dist = 0; waitTime=0; satisf = 0;
                return
            end
            
            if self.round == 1
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
            if self.round > self.nRounds
                dists = zeros(self.nSites, 1);
                waitTimes = zeros(self.nSites, 1);
                satisfs = zeros(self.nSites, 1);
                return
            end
            
            if self.round == 1
                waitTimes = self.lambdas;
                satisfs = self.means;
                dists = self.m0*ones(self.nSites, 1);
                return
            end
            
            dists = self.siteDist(site,:);
            waitTimes = self.lambdas;
            satisfs = self.means;
            
            %Set reward for current site to 0;
            satisfs(site) = 0;
        end
        
    end
end

