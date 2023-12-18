classdef StreamHandler < mlog.LogHandler
    %STREAMHANDLER Summary of this class goes here
    %   Detailed explanation goes here
        
    methods
        function writeMessage(~, msgStr)
            fprintf(1, msgStr + "\n");
        end
    end
end

