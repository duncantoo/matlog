classdef TestFileHandler < LogFileTestCase

    methods(Test)
        % Test methods
        function testFileCreation(testCase)
            % test the log file is created.
            testCase.verifyFalse(logical(exist(testCase.filepath, 'file')));
            matlog.FileHandler(testCase.filepath);
            testCase.verifyTrue(logical(exist(testCase.filepath, 'file')));
        end

        function testFormatter(testCase)
            % Use dummy format string with makeshift struct.
            % The struct needs the fields specified in the format string.
            % Check the resulting formatted output is correct.
            formatStr = "%(title)s no%(number)d by %(author)s";
            data = struct(...
                'title', 'Harry Potter',...
                'number', 5,...
                'author', 'JK Rowling'...
            );

            handler = matlog.FileHandler(testCase.filepath, 'format', formatStr);
            output = handler.formatFn(handler, data);

            expected = "Harry Potter no5 by JK Rowling";
            testCase.verifyEqual(output, expected);
        end

        function testLevelFilter(testCase)
            logger = matlog.logging.getLogger();
            logger.level = matlog.LogLevel.ALL;
            handler = matlog.FileHandler(testCase.filepath, 'level', 'WARN',...
                'format', '%(message)s');
            logger.addHandler(handler);
            logger.warning("This should be logged");
            logger.info("This should not be logged");
            logger.error("This definitely should be logged");

            testCase.verifyLogfileEqual([...
                "This should be logged";...
                "This definitely should be logged"...
            ])
        end
    end

end
