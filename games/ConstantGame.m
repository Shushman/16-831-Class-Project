classdef ConstantGame < Game
    %CONSTANTGAME Summary of this class goes here
    %   Detailed explanation goes here
    
    % Member variables to define the amusement park problem
    properties
        nSites      %Number of park sites
        siteDist    %Matrix of Pairwise distances between sites
        m0          %Fixed distance from starting point to all sites
        means       %1-x-n CURRENT Mean satisfaction from ride
        lambdas     % waittime
        
        map         % map, constains location
    end
    
    methods
        
        % Initializes game with parameters
        function self = ConstantGame(map,means,lambdas,nRounds,f,g,h)
            self.nSites = map.nSites;
            self.siteDist = map.siteDist;
            self.m0 = map.m0;
            self.map = map;
            
            self.means = means;
            self.lambdas = lambdas;
            self.nRounds = nRounds;
            
            assert (all(means >= 0) && all(means <= 1));
            assert (all(means >= 0) && all(lambdas <= 1));
            assert ((f+g+h) == 1);
            assert (all([f g h]) >= 0 && all([f g h] <= 1));
            
            self.weightDist = f;
            self.weightWait = g;
            self.weightRide = h;
            
            self.round = 0;
        end
        
 
        function [dist, waitTime, satisf] = get_eltwise_reward(self, site, next_site)
            
            self.round = self.round + 1;             
            if site < 1
                dist = self.m0*ones(1, self.nSites);
            else
                dist = self.siteDist(site,:)';
            end
            
            waitTime = self.lambdas;
            satisf = self.means;
            
            %Set reward for current site to 0;
%             if site > 0
%                 satisf(site) = 0;
%             end
            
            if nargin == 3
                dist = dist(next_site);
                waitTime = waitTime(next_site);
                satisf = satisf(next_site);
            end
            
        end
        
    end
end

