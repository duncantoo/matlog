classdef TestLogLevel < matlab.unittest.TestCase

    methods (TestClassSetup)
        function importPaths(~)
            addpath(fullfile(fileparts(fileparts(mfilename('fullpath')))));
        end
    end

    methods(Test)
        function testErrorBiggerThanWarning(testCase)
            testCase.verifyGreaterThan(matlog.LogLevel.ERROR, matlog.LogLevel.WARNING);
        end

        function testLevelsEqualToSelf(testCase)
            for level = enumeration(?matlog.LogLevel)'
                testCase.verifyEqual(level, level);
            end
        end

        function testLevelsInOrder(testCase)
            % Highest to lowest
            levelPrev = missing;
            for level = enumeration(?matlog.LogLevel)'
                if ~ismissing(levelPrev)
                    testCase.verifyLessThan(level, levelPrev);
                end
                levelPrev = level;
            end
        end
    end
end
