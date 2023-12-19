classdef Logger < handle
    %Logger accepts and dispatches messages to be logged by its handlers.
    %
    %Messages are filtered by level - only those meeting the minimum threshold
    %are passed on to its LogHandlers and parent Logger.
    %A Logger is hierarchical. Each Logger (except the root) has one parent.
    %The name determines the hierarchy as-per filepaths, but using '.' instead
    %of slashes.
    %A Logger has a number (maybe 0) of LogHandler instances. These are
    %responsible for formatting and writing the logs. A Logger with no
    %LogHandlers will not record anything.
    %
    %Create a Logger using logging.getLogger.
    %
    %See also logging, LogHandler.
    properties
        name
        handlers
    end
    properties (Access=protected)
        level_ = missing
    end

    properties (Dependent)
        level
    end

    properties (SetAccess = {?matlog.logging})
        parent
    end

    methods (Access = {?matlog.logging})
        function obj = Logger(name, parent, handlers, level)
            % Logger create a Logger instance. This can only be done by the
            % logging module. Use logging.getLogger.
            %
            % See also logging
            arguments
                name (1,1) string
                parent (1,1)
                handlers (:,1) cell
                level (1,1)
            end
            obj.name = name;
            obj.parent = parent;
            obj.handlers = handlers;
            obj.level = level;
        end
    end
    %%
    methods (Access = protected)
        function addMsg(obj, level, msg, varargin)
            arguments
                obj
                level (1,1) matlog.LogLevel
                msg string
            end
            arguments(Repeating)
                varargin
            end
            logRecord = matlog.LogRecord(obj, level, msg, varargin{:});
            obj.propagateRecord(logRecord);
        end

        function propagateRecord(obj, record)
            if record.level >= obj.level
                for iHandler = 1:length(obj.handlers)
                    obj.handlers{iHandler}.logRecord(record);
                end
                if ~ismissing(obj.parent)
                    record.logger = obj.parent;
                    obj.parent.propagateRecord(record);
                end
            end
        end
    end

    methods
        function obj = close(obj)
            obj.handlers = {};
        end

        function addHandler(obj, handler)
            arguments
                obj
                handler (1,1) matlog.LogHandler
            end
            obj.handlers = [obj.handlers(:)' {handler}];
        end

        % MATLAB is unhappy doing this in a getter so we make a function...
        function level = getlevel_(obj)
            level = obj.level_;
            if ismissing(level)
                level = obj.parent.getlevel_();
            end
        end

        function level = get.level(obj)
            level = obj.getlevel_();
        end

        function set.level(obj, level)
            obj.level_ = level;
        end

        %% Log commands for each level
        function trace(obj, msg, varargin)
            %trace log a message at level TRACE.
            %Syntax as-per sprintf.
            %See also sprintf.
            obj.addMsg(matlog.LogLevel.TRACE, msg, varargin{:});
        end

        function debug(obj, msg, varargin)
            %debug log a message at level DEBUG.
            %Syntax as-per sprintf.
            %See also sprintf.
            obj.addMsg(matlog.LogLevel.DEBUG, msg, varargin{:});
        end

        function info(obj, msg, varargin)
            %info log a message at level INFO.
            %Syntax as-per sprintf.
            %See also sprintf.
            obj.addMsg(matlog.LogLevel.INFO, msg, varargin{:});
        end

        function warning(obj, msg, varargin)
            %warning log a message at level WARNING.
            %Syntax as-per sprintf.
            %See also sprintf.
            obj.addMsg(matlog.LogLevel.WARNING, msg, varargin{:});
        end

        function error(obj, msg, varargin)
            %error log a message at level ERROR.
            %Syntax as-per sprintf.
            %See also sprintf.
            obj.addMsg(matlog.LogLevel.ERROR, msg, varargin{:});
        end

        function fatal(obj, msg, varargin)
            %fatal log a message at level FATAL.
            %Syntax as-per sprintf.
            %See also sprintf.
            obj.addMsg(matlog.LogLevel.FATAL, msg, varargin{:});
        end
        %%
        function exception(obj, exc, msg, options)
            %EXCEPTION log the message as an ERROR with the traceback.
            %
            %  EXCEPTION(exc) logs the provided MException traceback with no
            %  additional message.
            %  EXCEPTION(exc, msg) logs the provided MException traceback with
            %  the message at the start.
            %  EXCEPTION(__, 'splitlines', true) logs each individual line in
            %  the traceback with a new log entry. This is useful where an
            %  automated system requires each line to adhere to the format
            %  specification.
            arguments
                obj
                exc (1,1) MException
                msg (1,1) string = ""
                options.splitlines (1,1) logical = false
            end
            traceback = string(exc.getReport());
            lines = [msg; "Traceback:"; splitlines(traceback)];
            % Remove empty lines
            lines = lines(strlength(strip(lines)) > 0);

            if options.splitlines
                for line = lines'
                    obj.error(line);
                end
            else
                obj.error(join(lines, newline));
            end
        end
    end
end
