classdef LogRecord < handle
    %LogRecord Summary of this class goes here
    %   Detailed explanation goes here
   
    properties
        logger
    end

    properties (SetAccess = protected)
        level
        msg
        args
        time
    end

    properties (Access = protected)
        % stored values which can be requested and lazily evaluated
        % We store the traceback for speed. We might need to use it for several
        % fields.
        stack_ = missing
        callerStack_ = missing
        message_ = missing
    end

    %% properties which are really quick to compute; use getter to save clutter
    properties(Dependent)
        levelname
        levelno
        msecs
        name
        process
    end
   
    methods
        function obj = LogRecord(logger, level, msg, varargin)
            %LogRecord Construct an instance of this class f
            %   Detailed explanation goes here
            arguments
                logger (1,1) mlog.Logger
                level (1,1) mlog.LogLevel
                msg string
            end
            arguments(Repeating)
                varargin
            end
            obj.logger = logger;
            obj.level = level;
            obj.msg = msg;
            obj.args = varargin;
            obj.time = datetime("now");
        end
       
        function res = asctime(obj)
            res = obj.time;
        end

        function res = pathname(obj)
            stack = obj.callerStack;
            if isempty(stack)
                res = 'root';
            else
                res = stack(1).file;
            end
        end

        function res = filename(obj)
            [~, fname, fext] = fileparts(obj.pathname());
            res = join([fname, fext], '');
        end

        function res = funcName(obj)
            stack = obj.callerStack;
            if isempty(stack)
                res = 'root';
            else
                res = stack(1).name;
            end
        end

        function res = lineno(obj)
            stack = obj.callerStack;
            if isempty(stack)
                res = -1;
            else
            res = stack(1).line;
            end
        end

        function res = message(obj)
            res = obj.message_;
            if ismissing(res)
                res = sprintf(obj.msg, obj.args{:});
                obj.message_ = res;
            end
        end

        function res = get.levelname(obj)
            res = string(obj.level);
        end

        function res = get.levelno(obj)
            res = uint16(obj.level);
        end

        function res = get.msecs(obj)
            res = round(mod(second(obj.time), 1) * 1000);
        end

        function res = get.name(obj)
            res = obj.logger.name;
        end

        function res = get.process(obj)
            res = feature('getpid');
        end

        %% Getters for protected properties
        function res = stack(obj)
            res = obj.stack_;
            if ismissing(res)
                res = dbstack('-completenames', 0);
                obj.stack_ = res;
            end
        end

        function res = callerStack(obj)
            res = obj.callerStack_;
            if ismissing(res)
                stack = obj.stack;
                % Check for the most recent file in stack before mlog module
                filepaths = {stack.file};
                inModule = cellfun(@(p) ismember('+mlog', split(p, filesep)), filepaths);
                iEntry = find(inModule, 1, 'last');
                res = stack(iEntry + 1:end);
                obj.callerStack_ = res;
            end           
        end
    end
end

