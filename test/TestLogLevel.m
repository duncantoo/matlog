classdef TestLogLevel < matlab.unittest.TestCase

    methods (TestClassSetup)
        function importPaths(~)
            addpath(fullfile(...
                fileparts(fileparts(mfilename('fullpath'))),...
                'logging'...
            ));
        end
    end

    methods(Test)
        function testErrorBiggerThanWarning(testCase)
            testCase.verifyGreaterThan(LogLevel.ERROR, LogLevel.WARN);
        end

        function testLevelsEqualToSelf(testCase)
            for level = enumeration("LogLevel")'
                testCase.verifyEqual(level, level);
            end
        end

        function testLevelsInOrder(testCase)
            % Highest to lowest
            levelPrev = missing;
            for level = enumeration("LogLevel")'
                if ~ismissing(levelPrev)
                    testCase.verifyLessThan(level, levelPrev);
                end
                levelPrev = level;
            end
        end
    end
end
