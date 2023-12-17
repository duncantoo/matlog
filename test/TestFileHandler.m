classdef TestFileHandler < matlab.unittest.TestCase
    properties
        dir
        filepath
    end

    methods(TestClassSetup)
        function importPaths(~)
            addpath(fullfile(...
                fileparts(fileparts(mfilename('fullpath'))),...
                'logging'...
            ));
        end
    end

    methods(TestMethodSetup)
        % Setup for each test
        function fetchdir(obj)
            obj.filepath = tempname;
        end
    end

    methods(TestMethodTeardown)
        function cleartempfile(testCase)
            if exist(testCase.filepath, 'file')
                delete(testCase.filepath);
            end
        end
    end

    methods(Test)
        % Test methods
        function testFileCreation(testCase)
            % test the log file is created.
            testCase.verifyFalse(logical(exist(testCase.filepath, 'file')));
            FileHandler(testCase.filepath);
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

            handler = FileHandler(testCase.filepath, 'format', formatStr);
            output = handler.formatFn(handler, data);

            expected = "Harry Potter no5 by JK Rowling";
            testCase.verifyEqual(output, expected);
        end

        function testLevelFilter(testCase)
            logger = logging.getLogger();
            logger.level = LogLevel.ALL;
            handler = FileHandler(testCase.filepath, 'level', 'WARN');
            logger.addhandler(handler);
            logger.warning("This should be logged");
            logger.info("This should not be logged");
            logger.error("This definitely should be logged");
            
            lines = string(importdata(testCase.filepath));
            testCase.verifyLength(lines, 2);
            testCase.verifySubstring(lines(1), "This should be logged");
            testCase.verifySubstring(lines(2), "This definitely should be logged");
        end
    end
    
end
