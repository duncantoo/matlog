classdef (Abstract) LogFileTestCase < matlab.unittest.TestCase
    % LOGFILETESTCASE contains useful functions for testing contents of logfile
    properties
        filepath
    end

    methods(TestClassSetup)
        function importPaths(~)
            addpath(fullfile(fileparts(fileparts(mfilename('fullpath')))));
        end
    end

    methods(TestMethodSetup)
        % Setup for each test
        function fetchDir(obj)
            obj.filepath = tempname;
        end
    end

    methods(TestMethodTeardown)
        function clearTempFile(testCase)
            if exist(testCase.filepath, 'file')
                delete(testCase.filepath);
            end
        end

        function clearLogger(~)
            matlog.logging.clear();
        end
    end

    methods
        function verifyLogfileEqual(testCase, lines)
            arguments
                testCase
                lines (:, 1) string
            end
            logLines = string(importdata(testCase.filepath));
            testCase.verifyEqual(logLines, lines);
        end

        function verifyLogfileSubstrings(testCase, substrings)
            arguments
                testCase
                substrings (:, 1) string
            end
            logLines = string(importdata(testCase.filepath));
            nlines = length(substrings);
            testCase.verifyLength(logLines, nlines);
            for iline = 1:nlines
                testCase.verifySubstring(logLines(iline), substrings(iline));
            end
        end
    end
end
