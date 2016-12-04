function reward = compute_reward(wDist, wWait, wSatisf, dist, wait, satisf)
    w = [wDist; wWait; wSatisf];
    assert (all(w<=1) && all(w >= 0));
    assert (sum(w)==1);
    
    dist = reshape(dist, 1,[]);
    
    reward = wDist*(1-dist) + wWait*(1-wait) + wSatisf*satisf;
end


