classdef UCBPolicy < Policy
    %POLICYUCB This is a concrete class implementing UCB.

    properties
        % Member variables
        nSites
        sumSatisf
        sumWaitTime
        countObserved
        round
        lastAction
        ubSatisfs
        lbWaitTimes
        lastUb
        alpha
        siteDists
        game
        weightDist           % weight on distance
        weightWait          % weight on wait time
        weightRide           % weight on ride satisfaction
    end
    
    methods
        function self = UCBPolicy(game)
            % Initialize
            self.nSites = game.nSites;
            self.round = 0;
            self.siteDists = game.siteDist;
            self.weightDist = game.weightDist;
            self.weightWait = game.weightWait;
            self.weightRide = game.weightRide;
            self.game = game;
            
            self.sumSatisf = zeros(1, self.nSites);
            self.sumWaitTime = zeros(1, self.nSites);
            self.countObserved = 1e-5*ones(1, self.nSites);
            self.alpha = 0.1;
        end
        
        function action = decision(self, site, ~)
            % Choose action
            self.round = self.round + 1;
            C = self.countObserved;
            ubSatisf = (self.sumSatisf./C + sqrt(self.alpha*log(self.round)./(2*C)));
            lbWaitTime = (self.sumWaitTime./C - sqrt(self.alpha*log(self.round)./(2*C)));
            if self.round == 1
                dist = self.game.m0*ones(1, self.nSites);
            else
                dist = self.siteDists(site,:);
            end
            self.ubSatisfs = [self.ubSatisfs; clamp(ubSatisf)];
            self.lbWaitTimes = [self.lbWaitTimes; clamp(lbWaitTime)];
            
            if site > 0
                ubSatisf(site) = 0;
            end

            ubReward = compute_reward(self.weightDist, self.weightWait, self.weightRide, ...
                                     dist, lbWaitTime, ubSatisf);
                                     
            [maxV] = max(ubReward);  
            idx = find(ubReward == maxV);
            r = randsample(length(idx),1);
            action = idx(r);
        end
        
        function updatePolicy(self, prevsite, site, satisf, waittime)
            % Update ucb

            if prevsite ~= site
                self.sumWaitTime(site) = self.sumWaitTime(site) + waittime;
                self.countObserved(site) = floor(self.countObserved(site) + 1); 
                self.sumSatisf(site) = self.sumSatisf(site) + satisf;
            end

        end        
        
        function drawUpperBounds(self, satisfs, waittimes)
            figure(3);
            clf; 
            subplot(1,2,1);
            hold on;
            color = ['r','g','b','k','y'];
            for i = 1:self.nSites
                plot(self.ubSatisfs(:, i),'Color',color(i),'LineWidth',3);
                plot(1:self.round, ones(1,self.round)*satisfs(i),'--','Color',color(i),'LineWidth',1)
            end
            xlabel('Rounds','FontSize',20); ylabel('Upper bound','FontSize',20);
            title('Ride Satisfaction','FontSize',20)

            subplot(1,2,2);
            hold on;
            for i = 1:self.nSites
                plot(self.lbWaitTimes(:, i),'Color',color(i),'LineWidth',3);
                plot(1:self.round, ones(1,self.round)*waittimes(i),'--','Color',color(i),'LineWidth',2)
            end
            xlabel('Rounds','FontSize',20); ylabel('Lower bound','FontSize',20);
            title('Wait Time','FontSize',20)
            hold off;
            
            
        end
    end

end
