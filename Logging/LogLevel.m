classdef LogLevel < uint16

    methods
        function obj = LogLevel(value)
            obj@uint16(value)
        end
    end

    enumeration
        NONE (60)
        FATAL (50)
        ERROR (40)
        WARN (30)
        INFO (20)
        DEBUG (10)
        TRACE (5)
    end
end
