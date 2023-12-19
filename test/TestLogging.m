classdef TestLogging < LogFileTestCase

    methods(Test)
        % Test methods

        function testBasicConfigLevel(testCase)
            % Check the level property of the root logger is set properly.
            for level = enumeration(?matlog.LogLevel)'
                logging.basicConfig('level', level);
                logger = logging.getLogger();
                testCase.verifyEqual(logger.level, level);
            end
        end

        function testBasicConfigFormat(testCase)
            % Check basicConfig sets the log format properly.
            format = "%(level)s: hello %(message)s!";
            matlog.logging.basicConfig('level', 'ALL', 'format', format, ...
                'logfile', testCase.filepath);
            logger = matlog.logging.getLogger();
            logger.info("world");
            logger.close();

            testCase.verifyLogfileEqual("INFO: hello world!");
        end

        function testClear(testCase)
            % Create hierarchy of loggers.
            % Check that upon running logging.clear the loggers no longer work
            % and the hierarchy is clear.
            matlog.logging.basicConfig('logfile', testCase.filepath,...
                'format', '%(message)s');

            % Create root and 1st level
            logger_root = matlog.logging.getLogger();
            logger_a = matlog.logging.getLogger("a");
            logger_b = matlog.logging.getLogger("a.b");
            testCase.verifyEqual(logger_b.parent, logger_a);

            logger_b.error('First message');
            matlog.logging.clear();
            logger_b.error('Second message');
            testCase.verifyLogfileEqual('First message');

            matlog.logging.basicConfig('logfile', testCase.filepath);
            logger_root2 = matlog.logging.getLogger();

            testCase.verifyNotEqual(logger_root, logger_root2);
            logger_a2 = matlog.logging.getLogger("a");
            logger_b2 = matlog.logging.getLogger("a.b");
            testCase.verifyEqual(logger_b2.parent, logger_a2);
            testCase.verifyNotEqual(logger_b2.parent, logger_a);
        end
    end

end
