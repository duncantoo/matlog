classdef TestLogger < LogFileTestCase
 
    methods(Test)
        % Test methods

        function testRootCreation(testCase)
            logger = mlog.logging.getLogger();
            testCase.verifyEqual(logger.name, "root");
            testCase.verifyEqual(logger.parent, missing);
        end

        function testLoggerHierarchy(testCase)
            % Create hierarchy of loggers. Check the parent is linked and
            % updated properly.

            % Create root and 1st level
            logger_root = mlog.logging.getLogger();
            logger_a = mlog.logging.getLogger("a");

            % Names set correctly and parent of 1st level is root. Check the
            % loggers are indeed different.
            testCase.verifyEqual(logger_a.name, "a");
            testCase.verifyEqual(logger_a.parent, logger_root);
            testCase.verifyNotEqual(logger_a, logger_root);

            % Create a 2nd level logger on a different family tree.
            % It has no 1st level parent. Check its parent is instead root.
            logger_b_b1 = mlog.logging.getLogger("b.b1");
            testCase.verifyEqual(logger_b_b1.name, "b.b1");
            testCase.verifyEqual(logger_b_b1.parent, logger_root);

            % Create the parent for the 2nd level logger. Check the parents are
            % re-linked.
            logger_b = mlog.logging.getLogger("b");
            testCase.verifyEqual(logger_b.name, "b");
            testCase.verifyEqual(logger_b.parent, logger_root);
            testCase.verifyEqual(logger_b_b1.parent, logger_b);
        end

        function testLoggerLevelFilter(testCase)
            % Test a message at a low level is not logged but a high-level is.
            mlog.logging.basicConfig('logfile', testCase.filepath,...
                'level', 'WARN', 'format', '%(level)s - %(message)s');
            logger = mlog.logging.getLogger();
            logger.info("This should not be logged");
            logger.warning("This should be logged");
            logger.error("This definitely should be logged");
            logger.level = mlog.LogLevel.NONE;
            logger.error("This should not be logged");

            testCase.verifyLogfileEqual([...
                "WARNING - This should be logged",...
                "ERROR - This definitely should be logged"...
            ]);
        end
    end
 
end
