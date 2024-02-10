classdef FileHandler < matlog.LogHandler
    %FILEHANDLER stream logs to file.
    properties(SetAccess=protected)
        fileID = -1
        filepath
    end

    methods
        function obj = FileHandler(filepath, varargin)
            %FileHandler create a LogHandler which writes to the filesystem.
            %FileHandler is a subclass of LogHandler.
            %
            %  FileHandler(path, __) returns a FileHandler writing to the
            %  specified filepath in write-only mode by default.
            %  FileHandler(__, 'filemode', value) opens the file in the desired
            %  mode.
            %  FileHandler(__, 'level', value) specifies the minimum threshold
            %  for the entries being written.
            %  FileHandler(__, 'format', value) specifies the formatting of
            %  the logs.
            %  FileHandler(__, 'dateFormat', value) specifies the formatting of
            %  datetime fields in the log.
            %
            %See also LogHandler, fopen, string.
            parser = inputParser();
            parser.KeepUnmatched = true;
            parser.addRequired('filepath', @mustBeText);
            parser.addParameter('filemode', 'w', @mustBeText);
            parse(parser, filepath, varargin{:});
            unmatched = namedargs2cell(parser.Unmatched);

            obj@matlog.LogHandler(unmatched{:});
            obj.fileID = fopen(filepath, parser.Results.filemode);
            obj.filepath = filepath;
        end

        function delete(obj)
            fclose(obj.fileID);
        end

        function writeMessage(obj, msgStr)
            % Use format string to directly write our already-formatted message
            % which allows us to print special symbols like %.
            fprintf(obj.fileID, '%s\n', msgStr);
        end
    end
end

function mustBeText(x)
    if ~(isa(x, 'string') || isa(x, 'char'))
        error("Value of Data property must be string or char.")
    end
end
