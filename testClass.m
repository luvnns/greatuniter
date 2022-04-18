classdef testClass
    properties
        big
    end
    methods
        function obj = testClass(inputValue)
            obj.big = inputValue;
        end
    end
    methods %(Static)
        function p = product(obj,x)
            p = x * obj.big;
        end
    end
end