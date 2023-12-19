classdef logging
    % User access point for logging.
    % Use getLogger to create or retrieve an existing Logger.
    % Use basicConfig for simple log configuration.
    properties(Constant, Access=protected)
        loggers = containers.Map
    end
    properties(Constant)
        DEFAULTLEVEL = matlog.LogLevel.WARNING
        DEFAULTFORMAT = "%(asctime)s - %(name)s - %(level)-7s - %(message)s"
        DEFAULTDATEFORMAT = "yyyy-MM-dd HH:mm:ss.SSS"
    end

    methods(Static)
        function basicConfig(options)
            %basicConfig configure the root logger.
            %A StreamHandler will always be added.  
            %  basicConfig(__, 'level', value) sets the threshold level for
            %logging, defaulting to WARNING
            %  basicConfig(__, 'logfile', value) adds a FileHandler operaring
            %in write mode, writing to the specified filepath
            %  basicConfig(__, 'format', value) sets the log format used by the
            %handlers.
            arguments
                options.level (1,1) matlog.LogLevel = matlog.logging.DEFAULTLEVEL
                options.logfile (1,1) string = missing
                options.format (1,1) string = matlog.logging.DEFAULTFORMAT
            end
            matlog.logging.clear();
            rootLogger = matlog.logging.getLogger();
            rootLogger.level = options.level;
            streamHandler = matlog.StreamHandler('format', options.format);
            rootLogger.addHandler(streamHandler);
            if ~ismissing(options.logfile)
                fileHandler = matlog.FileHandler(options.logfile,...
                    'format', options.format);
                rootLogger.addHandler(fileHandler);
            end
        end

        function logger = getLogger(name)
            %getLogger make a new logger or retrieve an existing logger
            %
            %  getLogger(name) returns a logger with the desired name.
            %  getLogger() returns the root logger.
            %
            %If the logger already exists then return it, otherwise create a
            %new one.
            %The name acts as an ancestry tree, determining a hierarchy of
            %loggers.
            %See also Logger.
            arguments
                name (1,1) string = ""
            end
            loggers = matlog.logging.loggers;
            if isempty(loggers)
                loggers("") = matlog.Logger("root", missing, {},...
                    matlog.logging.DEFAULTLEVEL);
            end
            if ismember(name, keys(loggers))
                logger = loggers(name);
            else
                % Construct a new logger and track it for anyone who needs
                % access to the logger again. Also reset parent linking in
                % case it is parent to any pre-existing loggers.
                logger = matlog.Logger(name, missing, [], missing);
                loggers(name) = logger;
                names = string(keys(loggers));
                iParents = matlog.logging.findParents(names, names);
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
            parentFilter = arrayfun(@(p) children.startsWith(p), parents,...
                'UniformOutput', false);
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
            loggers = matlog.logging.loggers;
            for key_ = keys(loggers)
                key = key_{:};
                loggers(key).close();
                loggers.remove(key);
            end
        end
    end
end

