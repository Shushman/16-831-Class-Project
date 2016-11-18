function [policy,value,firstSite] = valueIterationOracleGame(oracleObj,f,g,h)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

policy = ones(1,oracleObj.nSites);
value = zeros(1,oracleObj.nSites);

t = 0;

while t < oracleObj.nRounds
    t = t+1;
    oldValue = value;
    for s = 1:oracleObj.nSites
        currRewards = oracleObj.get_all_rewards(s,f,g,h);
        
        % Get rewards from taking each action
        tempVals = currRewards + oldValue;
        [v,~] = max(tempVals);
        value(s) = v;
    end
    
end

% Get policy
for s = 1:oracleObj.nSites
    
    currRewards = oracleObj.get_all_rewards(s,f,g,h);
    tempVals = currRewards + value;
    
    [~,a] = max(tempVals);
    
    policy(s) = a;
end

% Get first action
initRewards = oracleObj.get_init_rewards(f,g,h);
tempVals = initRewards + value;
[~,firstSite] = max(tempVals);


end

