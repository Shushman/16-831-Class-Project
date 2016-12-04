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
            self.alpha = 1;
        end
        
        function action = decision(self, site, ~)
            % Choose action
            self.round = self.round + 1;
            C = self.countObserved;
            ubSatisf = self.sumSatisf./C + sqrt(self.alpha*log(self.round)./(2*C));
            lbWaitTime = self.sumWaitTime./C - sqrt(self.alpha*log(self.round)./(2*C));
            if self.round == 1
                dist = self.game.m0*ones(1, self.nSites);
            else
                dist = self.siteDists(site,:);
            end
            self.ubSatisfs = [self.ubSatisfs; ubSatisf];
            self.lbWaitTimes = [self.lbWaitTimes; lbWaitTime];
            
            if site > 0
                ubSatisf(site) = 0;
            end

            ubReward = compute_reward(self.weightDist, self.weightWait, self.weightRide, ...
                                     dist, lbWaitTime, ubSatisf);
                                     
            [~, action] = max(ubReward);  
        end
        
        function updatePolicy(self, prevsite, site, satisf, waittime)
            % Update ucb

            if prevsite ~= site
                self.sumWaitTime(site) = self.sumWaitTime(site) + waittime;
                self.countObserved(site) = floor(self.countObserved(site) + 1); 
                self.sumSatisf(site) = self.sumSatisf(site) + satisf;
            end

        end        
        
        function drawUpperBounds(self)
            figure(3);
            clf; hold on;
            for i = 1:self.nSites
                plot(self.ubSatisfs(:, i),'LineWidth',3);
            end
            xlabel('Rounds'); ylabel('Upper bound');
            title('Upper bound on Ride Satisfaction')
            
            figure(4)
            clf;
            hold on;
            for i = 1:self.nSites
                plot(self.lbWaitTimes(:, i),'LineWidth',3);
            end
            xlabel('Rounds'); ylabel('Lower bound');
            title('Lower bound on Wait Time')
            hold off;
            
            
        end
    end

end
