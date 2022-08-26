classdef testSubClass < testClass
    properties
        a
        result
    end
    methods
        function obj = testSubClass(a,big)
            obj = obj@testClass(big);
            obj.a = a;
        end
    
        function obj = useProduct(obj)
            obj.result = product(obj,obj.a);
        end
    end
end