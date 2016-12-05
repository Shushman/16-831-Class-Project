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
        map
    end
    
    methods
        
        % Initializes game with parameters
        function self = StaticGame(map,means,sigmas,...
                                   lambdas,nRounds,f,g,h)
                               
            assert (all(means >= 0) && all(means <= 1));
            assert (all(means >= 0) && all(lambdas <= 1));
            assert ((f+g+h) == 1);
            assert (all([f g h]) >= 0 && all([f g h] <= 1));
            assert (all(sigmas >= 0) && all(sigmas <=1));
            
            self.nSites = map.nSites;
            self.siteDist = map.siteDist;
            self.m0 = map.m0;
            self.map = map;
            
            self.means = means;
            self.sigmas = sigmas;
            self.lambdas = lambdas;
            self.nRounds = nRounds;
            self.weightDist = f;
            self.weightWait = g;
            self.weightRide = h;
            self.round = 0;
        end
        
        
        % Returns the elementwise reward for a single (state,action) pair
        function [dist, waitTime, satisf] = get_eltwise_reward(self, site, next_site)
            self.round = self.round + 1;
            
            if site == 0
                dist = self.m0*ones(self.nSites, 1);
            else
                dist = self.siteDist(site,:);
            end
            waitTime = clamp(normrnd(self.lambdas,self.sigmas));
            satisf = clamp(normrnd(self.means,self.sigmas));
            
            if site > 0
                %Set reward for current site to 0;
                satisf(site) = 0;
            end
            
            if nargin == 3
                dist = dist(next_site);
                waitTime = waitTime(next_site);
                satisf = satisf(next_site);
            end 
        end
        
    end
    
end

