classdef Agent < handle
    %AGENT One who actively moves around with a policy and collects reward
    
    properties
        policy
        cumReward % cumulative reward
        game
        site
        weightDist           % weight on distance
        weightWait          % weight on wait time
        weightRide           % weight on ride satisfaction
    end
    
    methods
        function self = Agent(policy, game)
            self.policy = policy;
            self.game = game;
            self.cumReward = 0;
            self.site = 0; %initial site
            self.weightDist = game.weightDist;
            self.weightWait = game.weightWait;
            self.weightRide = game.weightRide;
        end
        
        function [reward, nextsite, cumReward, satisf, waitTime] = ride(self)
            nextsite = self.policy.decision(self.site, self.game.round);
            [reward, ~, waitTime, satisf] = self.game.get_reward(self.site, nextsite); 
            self.cumReward = self.cumReward + reward;
            cumReward = self.cumReward;
            self.site = nextsite;
        end
 
    end
    
end

