classdef logging
    %LOGGING Summary of this class goes here
    %   Detailed explanation goes here
    properties(Constant, Access=protected)
        loggers = containers.Map
    end
    properties(Constant)
        DEFAULTLEVEL = mlog.LogLevel.WARNING
        DEFAULTFORMAT = "%(asctime)s - %(name)s - %(level)-7s - %(message)s"
        DEFAULTDATEFORMAT = "yyyy-MM-dd HH:mm:ss.SSS"
    end
    
    methods(Static)
        function basicConfig(options)
            arguments
                options.level (1,1) mlog.LogLevel = mlog.logging.DEFAULTLEVEL
                options.logfile (1,1) string = missing
                options.format (1,1) string = mlog.logging.DEFAULTFORMAT
            end
            mlog.logging.clear();
            rootLogger = mlog.logging.getLogger();
            rootLogger.level = options.level;
            streamHandler = mlog.StreamHandler('format', options.format);
            rootLogger.addhandler(streamHandler);
            if ~ismissing(options.logfile)
                fileHandler = mlog.FileHandler(options.logfile, 'format', options.format);
                rootLogger.addhandler(fileHandler);
            end
        end

        function logger = getLogger(name)
            %GETLOGGER make a new logger or return an existing logger
            % Return existing logger if one already exists.
            arguments
                name (1,1) string = ""
            end
            loggers = mlog.logging.loggers;
            if isempty(loggers)
                loggers("") = mlog.Logger("root", missing, [], mlog.logging.DEFAULTLEVEL);
            end
            if ismember(name, keys(loggers))
                logger = loggers(name);
            else
                % Construct a new logger and track it for anyone who needs
                % access to the logger again. Also reset parent linking in
                % case it is parent to any pre-existing loggers.
                logger = mlog.Logger(name, missing, [], missing);
                loggers(name) = logger;
                names = string(keys(loggers));
                iParents = mlog.logging.findParents(names, names);
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

        function clear()
            %CLEAR delete all loggers and reset tree.
            loggers = mlog.logging.loggers;
            for key_ = keys(loggers)
                key = key_{:};
                loggers(key).close();
                loggers.remove(key);
            end
        end
    end
end

