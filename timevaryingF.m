function [ func ] = timevaryingF( offset, ampt, T, phase_offset, sigma)
%TIMEVARYINGF Time-varying function. 
% Used for generating params for distributions.

assert (offset <=1 && offset >= -1);
assert (ampt <= 1 && ampt >= -1);

func = @(x) [clamp(offset+ampt*sin(2*pi/T*x+phase_offset)); sigma*ones(1,length(x))];

end

