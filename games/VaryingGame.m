classdef VaryingGame < Game
    %STATICGAME This class defines an amusement park setting.
    %   The rewards are static distributions
    
    % Member variables to define the amusement park problem
    properties
        nSites      %Number of park sites
        siteDist    %Matrix of Pairwise distances between sites
        m0          %Fixed distance from starting point to all sites
        meanss      %1-x-n CURRENT Mean satisfaction from ride
        sigmass     %1-x-n CURRENT Std. Deviations of rides
        fctnsw      %1-x-n Cell of Functions of means of waittimes
        sigmasw     %1-x-n CURRENT Std. Deviations of waittimes
        nRounds     %Rounds to run game for
        round       %current round
        pastRound
        weightDist           % weight on distance
        weightWait          % weight on wait time
        weightRide           % weight on ride satisfaction
    end
    
    methods
        
        % Initializes game with parameters
        function self = VaryingGame(nSites,siteDist,m0,meanss,sigmass,fctnsw,sigmasw,nRounds,f,g,h)
            self.nSites = nSites;
            self.siteDist = siteDist;
            self.m0 = m0;
            self.meanss = meanss;
            self.sigmass = sigmass;
            self.fctnsw = fctnsw;
            self.sigmasw = sigmasw;
            self.nRounds = nRounds;
            self.weightDist = f;
            self.weightWait = g;
            self.weightRide = h;
            self.round = 0;
            self.pastRound = 1e5*ones(1,nSites);
        end
        
        function reset(self)
            self.round = 0;
        end
        % Returns the reward for a single (state,action) pair
        function reward = get_reward(self, site, next_site)
            self.round = self.round + 1;

            if site < 1
                waitTime = normrnd(self.fctnsw{next_site}(self.nRounds),...
                    self.sigmasw(next_site));
                satisf = normrnd(self.meanss(next_site),self.sigmass(next_site));
                reward = -self.weightDist*self.m0 - self.weightWait*waitTime + self.weightRide*satisf;
                return
            end
            
            dist = self.siteDist(site,next_site);
            waitTime = max(normrnd(self.fctnsw{next_site}(self.nRounds),...
                    self.sigmasw(next_site)),0);
            self.pastRound = self.pastRound+1;
            self.pastRound(site) = 0;
            disp(self.pastRound);
            satisf = max(normrnd(self.meanss(next_site)...
                *(1-exp(-self.pastRound(next_site)/5))...
                ,self.sigmass(next_site)),0);
            % Signs reflect reward
            reward = -self.weightDist*dist - self.weightWait*waitTime + self.weightRide*satisf;
        end
        
        % Returns the elementwise reward for a single (state,action) pair
        function [dist, waitTime, satisf] = get_eltwise_reward(self, site, next_site)
            self.round = self.round + 1;
            
            if site < 1
                dist = self.m0;
                waitTime = normrnd(self.fctnsw{next_site}(self.nRounds),...
                    self.sigmasw(next_site));
                satisf = normrnd(self.meanss(next_site),self.sigmass(next_site));
                return
            end
            
            dist = self.siteDist(site,next_site);
            waitTime = max(normrnd(self.fctnsw{next_site}(self.nRounds),...
                    self.sigmasw(next_site)),0);
            self.pastRound = self.pastRound+1;
            self.pastRound(site) = 0;
            satisf = max(normrnd(self.meanss(next_site)...
                *(1-exp(-self.pastRound(next_site)/5)),...
                self.sigmass(next_site)),0);
        end      
    end
end

