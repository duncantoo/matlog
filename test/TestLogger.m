classdef TestLogger < matlab.unittest.TestCase
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

        function clearLogger(~)
            logging.clear();
        end
    end
    
    methods(Test)
        % Test methods

        function testRootCreation(testCase)
            logger = logging.getLogger();
            testCase.verifyEqual(logger.name, "root");
            testCase.verifyEqual(logger.parent, missing);
        end

        function testLoggerHierarchy(testCase)
            % Create hierarcy of loggers. Check the parent is linked and
            % updated properly.

            % Create root and 1st level
            logger_root = logging.getLogger();
            logger_a = logging.getLogger("a");

            % Names set correctly and parent of 1st level is root. Check the
            % loggers are indeed different.
            testCase.verifyEqual(logger_a.name, "a");
            testCase.verifyEqual(logger_a.parent, logger_root);
            testCase.verifyNotEqual(logger_a, logger_root);

            % Create a 2nd level logger on a different family tree.
            % It has no 1st level parent. Check its parent is instead root.
            logger_b_b1 = logging.getLogger("b.b1");
            testCase.verifyEqual(logger_b_b1.name, "b.b1");
            testCase.verifyEqual(logger_b_b1.parent, logger_root);

            % Create the parent for the 2nd level logger. Check the parents are
            % re-linked.
            logger_b = logging.getLogger("b");
            testCase.verifyEqual(logger_b.name, "b");
            testCase.verifyEqual(logger_b.parent, logger_root);
            testCase.verifyEqual(logger_b_b1.parent, logger_b);
        end

        function testLoggerLevelFilter(testCase)
            % Test a message at a low level is not logged but a high-level is.
            logging.basicconfig('level', 'WARN', 'logfile', testCase.filepath);
            logger = logging.getLogger();
            logger.info("This should not be logged");
            logger.warning("This should be logged");
            logger.error("This definitely should be logged");
            logger.level = LogLevel.NONE;
            logger.error("This should not be logged");

            lines = string(importdata(testCase.filepath));
            testCase.verifyLength(lines, 2);
            testCase.verifySubstring(lines(1), "This should be logged");
            testCase.verifySubstring(lines(1), "WARN");
            testCase.verifySubstring(lines(2), "This definitely should be logged");
            testCase.verifySubstring(lines(2), "ERROR");
        end
    end
    
end
