classdef EXP3Policy < Policy
    %EXP3Policy This is a concrete class that implements the EXP3
    %           algorithm for our problem setting
    
    properties
        %Member variables
        nSites
        weights
        lastAction
        round
        siteDists
        game
        weightDist
        weightWait
        weightRide
    end
    
    methods
        function self = EXP3Policy(game)
            
            self.nSites = game.nSites;
            self.round = 0;
            self.siteDists = game.siteDists;
            self.weightDist = game.weightDist;
            self.weightWait = game.weightWait;
            self.weightRide = game.weightRide;
            self.game = game;
            self.weights = ones(1,self.nSites);
            
        end
        
        function action = decision(self)
            
            self.round = self.round + 1;
            norm_wts = self.weights ./ sum(self.weights);
            action_vect = mnrnd(1,norm_wts);
            [~,action] = max(action_vect);
            self.lastAction = action;
        end
        
        function updatePolicy(self, reward)
            norm_wts = self.weights ./ sum(self.weights);
            
            % Check - IS this ok?
            lossScalar = -reward;
            
            lossVector = zeros(1,self.nSites);
            lossVector(self.lastAction) = lossScalar / norm_wts(self.lastAction);
            
            eta = sqrt(log(self.nSites)/(self.timestep*self.nSites));
            self.weights = self.weights.*exp(-eta*lossVector);
        end
            
        
    end
    
end

