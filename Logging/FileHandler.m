classdef FileHandler < LogHandler
    %FILEHANDLER stream logs to file.
    properties(SetAccess=protected)
        fileID = -1
    end

    methods
        function obj = FileHandler(filepath, filemode, varargin)
            obj@LogHandler(varargin{:});
            obj.fileID = fopen(filepath, filemode);
        end

        function delete(obj)
            fclose(obj.fileID);
        end 

        function writeMessage(obj, msgStr)
            fprintf(obj.fileID, msgStr + newline);
        end
    end
end

