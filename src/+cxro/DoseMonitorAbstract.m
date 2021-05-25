classdef DoseMonitorAbstract < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    
    
    methods
        
        function [dCounts, lSuccess] = getCounts(this)
            [cWord, lSuccess] = read();
            [cTiming, cIncrement, dSamples, dCounts] = getValuesFromDataWord(this, cWord);            
        end
               
    end
    
end

