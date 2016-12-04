classdef EXP3DPCompPolicy < Policy
    %EXP3Policy This is a concrete class that implements the EXP3
    %           algorithm for our problem setting
    
    properties
        %Member variables
        nSites
        weightSatisf;
        weightWaittime;
        lastAction
        round
        siteDists
        game
        weightDist
        weightWait
        weightRide
    end
    
    methods
        function self = EXP3DPCompPolicy(game)
            
            self.nSites = game.nSites;
            self.round = 0;
            self.siteDists = game.siteDist;
            self.weightDist = game.weightDist;
            self.weightWait = game.weightWait;
            self.weightRide = game.weightRide;
            self.game = game;
            self.weightSatisf = ones(1,self.nSites);
            self.weightWaittime = ones(1,self.nSites);
            
        end
        
        function norm_wts = get_norm_wts(self, site)
            if site == 0
                norm_wts = ones(1,self.nSites)/self.nSites;
            else
                satisf = self.weightSatisf/ sum(self.weightSatisf);
                wait = self.weightWaittime/ sum(self.weightWaittime);
                dist = self.siteDists(site,:)/sum(self.siteDists(site,:));
                weights = dist*self.weightDist + ...
                          satisf*self.weightRide + ...
                          wait*self.weightWait;
                norm_wts = weights ./ sum(weights);
            end
        end
            
        function action = decision(self,site,~)         
            self.round = self.round + 1;
            norm_wts = self.get_norm_wts(site);
            action_vect = mnrnd(1,norm_wts);
            [~,action] = max(action_vect);
        end
        
        function updatePolicy(self, prevsite, site, satisf, waittime)
            if prevsite == 0
                return
            end
            
            assert(satisf >= 0 && satisf <= 1);
            assert(waittime >= 0 && waittime <= 1);

            % update satisf weights
            norm_wts = self.get_norm_wts(site);
            if norm_wts(site) < 1e-5
                return;
            end
            
            lossScalar = 1-satisf;
            lossVector = zeros(1,self.nSites);
            lossVector(site) = lossScalar / norm_wts(site);
            eta = sqrt(log(self.nSites)/(self.round*self.nSites));
            self.weightSatisf = self.weightSatisf.*exp(-eta*lossVector*1e-10);

            % update waittime weights
            lossScalar = 1-waittime;
            lossVector = zeros(1,self.nSites);
            lossVector(site) = lossScalar / norm_wts(site);
            self.weightWaittime = self.weightWaittime.*exp(-eta*lossVector*1e-10);

        end
            
        
    end
    
end

