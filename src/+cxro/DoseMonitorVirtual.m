classdef DoseMonitorVirtual < cxro.DoseMonitorAbstract
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = private)
        
        
    end
    
    methods
        
        function this = DoseMonitorVirtual(varargin)
            for k = 1 : 2: length(varargin)
                this.msg(sprintf('passed in %s', varargin{k}));
                if this.hasProp( varargin{k})
                    this.msg(sprintf('settting %s', varargin{k}));
                    this.(varargin{k}) = varargin{k + 1};
                end
            end
                        
        end
                
        function [dCounts, lSuccess] = getCounts(this)
            lSuccess = true;
            dCounts = 1000 + floor(500 * rand);     
        end
        
        function [dVal, lSuccess] = getCharge(this, dGain)
            
            lSuccess = true;
            dVal = rand*5e9;

        end
        
        
        
    end
    
end

