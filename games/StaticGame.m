classdef StaticGame < Game
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
        nRounds     %Rounds to run game for
        round       % current round
        f           % weight on distance
        g           % weight on wait time
        h           % weight on ride satisfaction
    end
    
    methods
        
        % Initializes game with parameters
        function self = StaticGame(nSites,siteDist,m0,means,sigmas,lambdas,nRounds,f,g,h)
            self.nSites = nSites;
            self.siteDist = siteDist;
            self.m0 = m0;
            self.means = means;
            self.sigmas = sigmas;
            self.lambdas = lambdas;
            self.nRounds = nRounds;
            self.f = f;
            self.g = g;
            self.h = h;
            self.round = 0;
        end
            
        % Returns the reward for a single (state,action) pair
        function reward = get_reward(self, site, next_site)
            self.round = self.round + 1;
            if self.round > self.nRounds
                reward = 0;
                return
            end
            
            if self.round == 1
                waitTime = poissrnd(self.lambdas(next_site));
                satisf = normrnd(self.means(next_site),self.sigmas(next_site));
                reward = -self.f*self.m0 - self.g*waitTime + self.h*satisf;
                return
            end
            
            dist = self.siteDist(site,next_site);
            waitTime = poissrnd(self.lambdas(next_site));
            if site ~= next_site
                satisf = normrnd(self.means(next_site),self.sigmas(next_site));
            else
                satisf = 0;
            end
            % Signs reflect reward
            reward = -self.f*dist - self.g*waitTime + self.h*satisf;
        end
        
        % Returns vector of rewards for all actions from a given state
        function rewards = get_all_rewards(self, site)
            self.round = self.round + 1;
            if self.round > self.nRounds
                rewards = zeros(self.nSites, 1);
                return
            end
            
            if self.round == 1
                waitTimes = poissrnd(self.lambdas);
                satisfs = normrnd(self.means,self.sigmas);
                satisfs(site) = 0;
                rewards = -self.f*self.m0*ones(size(self.means)) -self.g*waitTimes + self.h*satisfs;
                return
            end
            
            %TODO - need to discourage just taking same ride
            dists = self.siteDists(site,:);
            waitTimes = poissrnd(self.lambdas);
            satisfs = normrnd(self.means,self.sigmas);

            %Set reward for current site to 0;
            satisfs(site) = 0;
            rewards = -self.f*dists - self.g*waitTimes + self.h*satisfs;
        end
        
    end
    
end

