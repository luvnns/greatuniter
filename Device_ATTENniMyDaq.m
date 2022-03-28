classdef Device_ATTENniMyDaq
    properties (Constant)
        name = "myDAQ1"
        channel = "ao0"
        type = "Voltage"
    end
    properties
        funcAttenVolt
        virtualObject
    end
    properties
        lastAttenuation
    end
    methods
        function obj = Device_ATTENniMyDaq(app)
            obj.funcAttenVolt = app.funcAttenVolt;
            obj.virtualObject = daq("ni");
            addoutput(obj.virtualObject, obj.name, obj.channel, obj.type);
            %obj = setAttenuation(obj,0);
        end
        function obj = setAttenuation(obj,attenuation)
            output = obj.funcAttenVolt(attenuation);
            write(obj.virtualObject,output);
            obj.lastAttenuation = attenuation;
        end
        function obj = deleteVirtualObject(obj)
            flush(obj.virtualObject);
            delete(obj.virtualObject);
        end
    end
end