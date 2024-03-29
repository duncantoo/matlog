classdef (Abstract) LogHandler < handle
    %LOGHANDLER Abstract class which formats LogRecord objects to string and
    %writes them (abstractly!)
    %The writeMessage method is customised by derived classes.

    properties
        level (1,1) matlog.LogLevel
        dateFormat (1,1) string
    end
    properties(Constant)
        DEFAULTLEVEL = matlog.LogLevel.ALL
    end
    properties (SetAccess=private)
        % formatFn format a LogRecord to string according to a specification in
        % the form "__%(fieldname)s__".
        %
        % The field names must occur as properties or methods of LogRecord.
        %
        % See also LogRecord.
        formatFn
    end
    properties (Access=private)
        format_
    end
    properties (Dependent)
        % FORMAT a string which specifies the log format.
        format
    end

    methods
        function obj = LogHandler(options)
            % LogHandler Create a LogHandler instance.
            %
            %  LogHandler(__, 'level', value) specifies the minimum threshold
            %  for the entries being written. Defaults to ALL.
            %  LogHandler(__, 'format', value) specifies the formatting of
            %  the logs.
            %  See also formatFn.
            %  LogHandler(__, 'dateFormat', value) specifies the formatting of
            %  datetime fields in the log.
            arguments
                options.level (1,1) matlog.LogLevel = matlog.LogHandler.DEFAULTLEVEL
                options.format (1,1) string = matlog.logging.DEFAULTFORMAT
                options.dateFormat (1,1) string = matlog.logging.DEFAULTDATEFORMAT
            end
            obj.level = options.level;
            obj.format = options.format;
            obj.dateFormat = options.dateFormat;
        end

        function logRecord(obj, record)
            %logRecord format and write the LogRecord.
            arguments
                obj
                record (1,1) matlog.LogRecord
            end
            if record.level >= obj.level
                msgFormatted = obj.formatFn(obj, record);
                obj.writeMessage(msgFormatted);
            end
        end

        function formatStr = get.format(obj)
            formatStr = obj.format_;
        end

        function set.format(obj, formatStr)
            % Interpret the formatStr.
            arguments
                obj
                formatStr (1,1) string
            end
            obj.format_ = formatStr;
            allowedFields = string(matlog.LogRecord.formatFields);

            [tokens, tokenExtents] = regexp(...
                formatStr, "%\((\w+)\)", 'tokens', 'tokenExtents');
            tokens = string(tokens);

            % Check if the tokens are valid formatFields.
            isValid = cellfun(@(x) ismember(x, allowedFields), tokens);
            goodTokens = tokens(isValid);
            tokenExtents = tokenExtents(isValid);
            % Convert the input format string to a valid MATLAB format string
            % by removing the (fieldname) part.
            matlabFmt = formatStr;
            for extents = tokenExtents(end:-1:1)
                ext = extents{1};
                matlabFmt = eraseBetween(matlabFmt, ext(1) - 1, ext(2) + 1);
            end
            function msgFormatted = formatFn(obj, record)
                recordFields = cell(length(goodTokens), 1);
                for ii = 1:length(goodTokens)
                    fieldName = goodTokens{ii};
                    val = record.(fieldName);
                    if isdatetime(val)
                        val = string(val, obj.dateFormat);
                    end
                    recordFields{ii} = val;
                end
                msgFormatted = sprintf(matlabFmt, recordFields{:});
            end
            obj.formatFn = @formatFn;
            % Warn about failed tokens
            badTokens = tokens(~isValid);
            if ~isempty(badTokens)
                warning(...
                    'matlog:LogHandler:invalidFormatter', ...
                    ['The following log format tokens are not understood: ' ...
                    '%s\nA complete list is: %s'], ...
                    join(badTokens, ', '), ...
                    join(allowedFields, ', ')...
                );
            end
        end
    end

    methods (Abstract)
        %writeMessage abstract method to output LogRecord
        writeMessage(msgStr)
    end
end
