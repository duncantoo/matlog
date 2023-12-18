classdef Logger < handle
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

    properties (SetAccess = {?mlog.logging})
        parent
    end

    %% Constructor
    % logging class is responsible for creating loggers.
    methods (Access = {?mlog.logging})
        function obj = Logger(name, parent, handlers, level)
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
        function addmsg(obj, level, msg, varargin)
            arguments
                obj
                level (1,1) mlog.LogLevel
                msg string
            end
            arguments(Repeating)
                varargin
            end
            logRecord = mlog.LogRecord(obj, level, msg, varargin{:});
            obj.propagaterecord(logRecord);
        end

        function propagaterecord(obj, record)
            if record.level >= obj.level
                for iHandler = 1:length(obj.handlers)
                    obj.handlers{iHandler}.logrecord(record);
                end
                if ~ismissing(obj.parent)
                    record.logger = obj.parent;
                    obj.parent.propagaterecord(record);
                end
            end
        end
    end

    methods
        function obj = close(obj)
            obj.handlers = {};
        end

        function addhandler(obj, handler)
            arguments
                obj
                handler (1,1) mlog.LogHandler
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
            obj.addmsg(mlog.LogLevel.TRACE, msg, varargin{:});
        end

        function debug(obj, msg, varargin)
            obj.addmsg(mlog.LogLevel.DEBUG, msg, varargin{:});
        end

        function info(obj, msg, varargin)
            obj.addmsg(mlog.LogLevel.INFO, msg, varargin{:});
        end

        function warning(obj, msg, varargin)
            obj.addmsg(mlog.LogLevel.WARNING, msg, varargin{:});
        end

        function error(obj, msg, varargin)
            obj.addmsg(mlog.LogLevel.ERROR, msg, varargin{:});
        end

        function fatal(obj, msg, varargin)
            obj.addmsg(mlog.LogLevel.FATAL, msg, varargin{:});
        end
        %%
        function exception(obj, exc, msg, options)
            % EXCEPTION log the message as an ERROR with the traceback.
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
