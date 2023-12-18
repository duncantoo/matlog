classdef StreamHandler < mlog.LogHandler
    %STREAMHANDLER stream logs to std out.
    %
    %See also LogHandler.

    methods
        function writeMessage(~, msgStr)
            fprintf(1, msgStr + "\n");
        end
    end
end

