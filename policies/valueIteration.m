function [policy,value,firstSite] = valueIteration(gameObj)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

policy = FullDPPolicy(gameObj);
value = zeros(1,gameObj.nSites);

lambda = 1;
t = 0;
N = gameObj.nSites;
while t<3000
    t = t+1;
    oldValue = value;
    % generate random ordering
    idx = randperm(N);
    for i = 1:N
%         s = idx(i);
        s = i;
        currRewards = gameObj.get_reward(s);
        
        % Get rewards from taking each action
       
        tempVals = currRewards + lambda*oldValue;
        [v,~] = max(tempVals);
        value(s) = v;
    end
    % check termination
%     dv = norm(value - oldValue);
%     sumv = sum(value);
%     disp(['t: ' num2str(t) ' dv: ' num2str(dv) ' sum:' num2str(sumv)]);
%     if dv < 1e-8
%         break;
%     end
end

% Get policy
for s = 1:gameObj.nSites
    currRewards = gameObj.get_reward(s);
    tempVals = currRewards + value;
    
    [~,a] = max(tempVals);
    policy.update(s, a);
end

initRewards = gameObj.get_reward(0);
tempVals = initRewards + value;
[~,firstSite] = max(tempVals);
policy.update(0, firstSite);

end

