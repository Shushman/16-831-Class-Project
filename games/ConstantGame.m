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
            self.round = self.round + 1;
            if self.round > self.nRounds
                reward = 0;
                return
            end
            
            
            if self.round == 1
                waitTime = self.lambdas(next_site);
                satisf = self.means(next_site);
                reward = -self.f*self.m0 - self.g*waitTime + self.h*satisf;
                return
            end
            
            dist = self.siteDist(site,next_site);
            waitTime = self.lambdas(next_site);
            
            %Set reward for current site to 0;
            if site == next_site
                satisf = 0;
            else
                satisf = self.means(next_site);
            end
            
            reward = -self.f*dist - self.g*waitTime + self.h*satisf;
        end
        
        function rewards = get_all_rewards(self, site)
            self.round = self.round + 1;
            if self.round > self.nRounds
                rewards = zeros(self.nSites, 1);
                return
            end
            
            if self.round == 1
                waitTimes = self.lambdas;
                satisfs = self.means;
                rewards = -self.f*self.m0 - self.g*waitTimes + self.h*satisfs;
                return
            end
            
            dists = self.siteDist(site,:);
            waitTimes = self.lambdas;
            satisfs = self.means;
            
            %Set reward for current site to 0;
            satisfs(site) = 0;
            
            rewards = -self.f*dists - self.g*waitTimes + self.h*satisfs;
        end
        
        
    end
end

