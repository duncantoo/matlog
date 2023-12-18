classdef FileHandler < mlog.LogHandler
    %FILEHANDLER stream logs to file.
    properties(SetAccess=protected)
        fileID = -1
    end

    methods
        function obj = FileHandler(filepath, varargin)
            parser = inputParser();
            parser.KeepUnmatched = true;
            parser.addRequired('filepath', @mustBeText);
            parser.addParameter('filemode', 'w', @mustBeText);
            parse(parser, filepath, varargin{:});
            unmatched = namedargs2cell(parser.Unmatched);

            obj@mlog.LogHandler(unmatched{:});
            obj.fileID = fopen(filepath, parser.Results.filemode);
        end

        function delete(obj)
            fclose(obj.fileID);
        end

        function writeMessage(obj, msgStr)
            fprintf(obj.fileID, msgStr + newline);
        end
    end
end

