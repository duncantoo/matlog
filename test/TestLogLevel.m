classdef TestLogLevel < matlab.unittest.TestCase

    methods (TestClassSetup)
        function importPaths(~)
            addpath(fullfile(fileparts(fileparts(mfilename('fullpath')))));
        end
    end

    methods(Test)
        function testErrorBiggerThanWarning(testCase)
            testCase.verifyGreaterThan(mlog.LogLevel.ERROR, mlog.LogLevel.WARNING);
        end

        function testLevelsEqualToSelf(testCase)
            for level = enumeration(?mlog.LogLevel)'
                testCase.verifyEqual(level, level);
            end
        end

        function testLevelsInOrder(testCase)
            % Highest to lowest
            levelPrev = missing;
            for level = enumeration(?mlog.LogLevel)'
                if ~ismissing(levelPrev)
                    testCase.verifyLessThan(level, levelPrev);
                end
                levelPrev = level;
            end
        end
    end
end
