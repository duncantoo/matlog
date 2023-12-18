classdef TestFormatting < LogFileTestCase

    methods(Test)
        % Test methods

        function testFilename(testCase)
            % Check the filename is interpretted properly.
            mlog.logging.basicConfig('format', '%(filename)s',...
                'logfile', testCase.filepath);
            logger = mlog.logging.getLogger();
            logger.error('');
            testCase.verifyLogfileEqual(sprintf("%s.m", mfilename()));
        end

        function testFunctionName(testCase)
            % Check the filename is interpretted properly.
            mlog.logging.basicConfig('format', '%(funcName)s',...
                'logfile', testCase.filepath);
            logger = mlog.logging.getLogger();
            logger.error('');
            testCase.verifyLogfileEqual("TestFormatting.testFunctionName");
        end

        function testBasicConfigFormat(testCase)
            % Check basicConfig sets the log format properly.
            format = "%(level)s: hello %(message)s!";
            mlog.logging.basicConfig('level', 'ALL', 'format', format, ...
                'logfile', testCase.filepath);
            logger = mlog.logging.getLogger();
            logger.info("world");

            testCase.verifyLogfileEqual("INFO: hello world!");
        end

        function testClear(testCase)
            % Create hierarchy of loggers.
            % Check that upon running logging.clear the loggers no longer work
            % and the hierarchy is clear.
            mlog.logging.basicConfig('logfile', testCase.filepath);

            % Create root and 1st level
            logger_root = mlog.logging.getLogger();
            logger_a = mlog.logging.getLogger("a");
            logger_b = mlog.logging.getLogger("a.b");
            testCase.verifyEqual(logger_b.parent, logger_a);

            logger_b.error('First message');
            mlog.logging.clear();
            logger_b.error('Second message');
            % We only have the first message and not the second.
            testCase.verifyLogfileSubstrings("First message");

            mlog.logging.basicConfig('logfile', testCase.filepath);
            logger_root2 = mlog.logging.getLogger();

            testCase.verifyNotEqual(logger_root, logger_root2);
            logger_a2 = mlog.logging.getLogger("a");
            logger_b2 = mlog.logging.getLogger("a.b");
            testCase.verifyEqual(logger_b2.parent, logger_a2);
            testCase.verifyNotEqual(logger_b2.parent, logger_a);
        end
    end

end
