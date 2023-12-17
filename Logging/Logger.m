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

    properties (SetAccess = protected)
        parent
        active = false;
    end

    methods (Access = protected)
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
            obj.active = true;
        end

        function addmsg(obj, level, msg, varargin)
            arguments
                obj
                level (1,1) LogLevel
                msg string
            end
            arguments(Repeating)
                varargin
            end
            logRecord = LogRecord(obj, level, msg, varargin{:});
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

    methods(Static)
        function obj = getLogger(name)
            %GETLOGGER make a new logger or return an existing logger
            % Return existing logger if one already exists.
            arguments
                name (1,1) string = ""
            end
            persistent loggers;
            if isempty(loggers)
                loggers = containers.Map;
                loggers("") = Logger("root", missing, [], LogLevel.WARN);
            end
            if ismember(name, keys(loggers))
                obj = loggers(name);
            else
                % Construct a new logger and track it for anyone who needs
                % access to the logger again. Also reset parent linking in
                % case it is parent to any pre-existing loggers.
                obj = Logger(name, missing, [], missing);
                loggers(name) = obj;
                names = string(keys(loggers));
                iParents = obj.findParents(names, names);
                for iChild = 1:length(loggers)
                    iParent = iParents(iChild);
                    if isnan(iParent)
                        continue
                    end
                    child = loggers(names(iChild));
                    parent = loggers(names(iParent));
                    child.parent = parent;
                end
            end
        end

        function iParent = findParents(children, parents)
            %FINDPARENTS return the index of the parent to each child, or NaN.
            % We match grandparents and older generations if no exact parent
            % exists.
            arguments
                children (:,1) string
                parents (1,:) string
            end
            % Every parent must form the start of its child.
            % We may pick up some grand-parents etc. or siblings with different
            % stems.
            parentFilter = arrayfun(@(p) children.startsWith(p), parents, 'UniformOutput', false);
            parentFilter = cat(2, parentFilter{:});
            % Filter out siblings by checking number of levels.
            % We treat the empty string differently, having 0 levels.
            ncLevels = count(children, ".") + (strlength(children) > 0);
            npLevels = count(parents, ".") + (strlength(parents) > 0);
            % Valid parents will have a smaller number of levels.
            parentFilter = parentFilter & (ncLevels > npLevels);
            % Filter out older generations by picking the match with the
            % highest number of levels.
            parentScore = parentFilter .* (1 + npLevels);
            [score, iParent] = max(parentScore, [], 2);
            iParent(score == 0) = missing;
        end
    end

    methods
        function addhandler(obj, handler)
            arguments
                obj
                handler (1,1) LogHandler
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
        function logstr = trace(obj, msg, varargin)
            logstr = obj.addmsg(LogLevel.TRACE, msg, varargin{:});
        end

        function debug(obj, msg, varargin)
            obj.addmsg(LogLevel.DEBUG, msg, varargin{:});
        end

        function info(obj, msg, varargin)
            obj.addmsg(LogLevel.INFO, msg, varargin{:});
        end

        function warning(obj, msg, varargin)
            obj.addmsg(LogLevel.WARN, msg, varargin{:});
        end

        function error(obj, msg, varargin)
            obj.addmsg(LogLevel.ERROR, msg, varargin{:});
        end

        function fatal(obj, msg, varargin)
            obj.addmsg(LogLevel.FATAL, msg, varargin{:});
        end
        %%
        function log_exception(obj, exc)
            arguments
                obj
                exc MException
            end
            obj.error(sprintf('Exception %s - %s', exc.identifier, exc.message));
            for s = exc.stack'
                [~, base, ext] = fileparts(s.file);
                obj.error(sprintf('  Error in %s: %s (line %d)', [base, ext], s.name, s.line));
            end
            if ~isempty(exc.cause)
                obj.error('Cause:');
                for c = exc.cause'
                    obj.error(sprintf('  %s', c));
                end
            end
        end
    end
end
