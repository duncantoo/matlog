classdef StreamHandler < matlog.LogHandler
    %STREAMHANDLER stream logs to IO streams.
    %
    %See also LogHandler.

    properties(Constant)
        DEAFULTIOSTREAM = 1
    end
    properties
        streamID
    end

    methods
        function obj = StreamHandler(varargin)
            %StreamHandler create a LogHandler which writes to the console (IO
            %streams). StreamHandler is a subclass of LogHandler.
            %
            %  StreamHandler(streamID, __) returns a StreamHandler writing to
            %  the specified IO stream (1: stdout, 2: stderr). Defaults to
            %  stdout.
            %  StreamHandler(__, 'level', value) specifies the minimum
            %  threshold for the entries being written.
            %  StreamHandler(__, 'format', value) specifies the formatting of
            %  the logs.
            %  StreamHandler(__, 'dateFormat', value) specifies the formatting
            %  of datetime fields in the log.
            %
            %See also LogHandler, string.
            parser = inputParser();
            parser.KeepUnmatched = true;
            parser.addOptional(...
                'streamID', matlog.StreamHandler.DEAFULTIOSTREAM,...
                @(x) ismember(x, [1,2])...
            );
            parse(parser, varargin{:});
            unmatched = namedargs2cell(parser.Unmatched);

            obj@matlog.LogHandler(unmatched{:});
            obj.streamID = parser.Results.streamID;
        end

        function writeMessage(obj, msgStr)
            fprintf(obj.streamID, msgStr + newline);
        end
    end
end

