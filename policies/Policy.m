classdef (Abstract) Policy < handle
    %POLICY This is an abstract class defining a policy.
    
    methods (Abstract)
        % Choose next site 
        nextsite = decision(self, site, round); 
    end
    
end
