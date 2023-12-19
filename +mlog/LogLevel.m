classdef LogLevel < uint16
    %LogLevel an enumeration of logging severities.
    %Each level is associated with a uint16 value and may be ordered by
    %severity.
    methods
        function obj = LogLevel(value)
            obj@uint16(value)
        end
    end

    enumeration
        NONE (60)
        FATAL (50)
        ERROR (40)
        WARNING (30)
        INFO (20)
        DEBUG (10)
        TRACE (5)
        ALL (0)
    end
end
