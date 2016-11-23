function [policy,value,firstSite] = valueIteration(gameObj,f,g,h)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

policy = FullDPPolicy(gameObj);
value = zeros(1,gameObj.nSites);

t = 0;

while t < gameObj.nRounds
    t = t+1;
    oldValue = value;
    for s = 1:gameObj.nSites
        currRewards = gameObj.get_all_rewards(s);
        
        % Get rewards from taking each action
        tempVals = currRewards + oldValue;
        [v,~] = max(tempVals);
        value(s) = v;
    end
    
end

% Get policy
for s = 1:gameObj.nSites
    currRewards = gameObj.get_all_rewards(s);
    tempVals = currRewards + value;
    
    [~,a] = max(tempVals);
    policy.update(s, a);
end

initRewards = gameObj.get_all_rewards(0);
tempVals = initRewards + value;
[~,firstSite] = max(tempVals);
policy.update(0, firstSite);

end

