classdef VaryingGame < Game
    %STATICGAME This class defines an amusement park setting.
    %   The rewards are static distributions
    
    % Member variables to define the amusement park problem
    properties
        nSites      %Number of park sites
        siteDist    %Matrix of Pairwise distances between sites
        
        m0          %Fixed distance from starting point to all sites
        satisfMeans
        satisfSigmas
        waitTimeF   %Function that generates mean and sigma of waitTime
        pastRound   % number of rounds since previous visit
        map
        
    end
    
    methods
        
        % Initializes game with parameters
        function self = VaryingGame(map, satisfMeans, satisfSigmas, waitTimeF, f, g, h, nRounds)

            self.nSites = map.nSites;
            self.siteDist = map.siteDist;
            self.m0 = map.m0;
            self.map = map;
            self.nRounds = nRounds;
            
            assert ((f+g+h) == 1);
            assert (all([f g h]) >= 0 && all([f g h] <= 1));
            self.weightDist = f;
            self.weightWait = g;
            self.weightRide = h;
            
            self.satisfMeans = satisfMeans;
            self.satisfSigmas = satisfSigmas;
            self.waitTimeF = waitTimeF;
            
            self.round = 0;
            self.pastRound = 1e3*ones(1,self.nSites); % Haven't visited in a while!
        end
        
        function reset(self)
            self.round = 0;
            self.pastRound = 1e3*ones(1,self.nSites); % Haven't visited in a while!
        end
           
        function [dist, waitTime, satisf] = get_eltwise_reward(self, site, next_site)
            self.round = self.round + 1;
            
            if site < 1
                dist = self.m0*ones(1,self.nSites);
            else
                dist = self.siteDist(site,:);
            end
            
            if nargin == 2
                waitTime = zeros(1, self.nSites);
                satisf = zeros(1, self.nSites);
                for i = 1:self.nSites
                    [w] = self.waitTimeF{i}(self.round);
                    waitTime(i) = clamp(normrnd(w(1), w(2)));
                    satisf(i) = clamp(normrnd(self.satisfMeans(i)...
                                        *(1-exp(-self.pastRound(i))),...
                                       self.satisfSigmas(i))); 
                end
            else
                dist = dist(next_site);
                [w] = self.waitTimeF{next_site}(self.round);
                waitTime = clamp(normrnd(w(1), w(2)));
                satisf = clamp(normrnd(self.satisfMeans(next_site)...
                                        *(1-exp(-self.pastRound(next_site))),...
                                       self.satisfSigmas(next_site))); 
            end
            
            % site has just been visited.
            self.pastRound = self.pastRound+1;
            if site > 0
                self.pastRound(site) = 0;  
            end
        end
        
    end
end

