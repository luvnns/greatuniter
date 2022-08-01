classdef Device_ATTENniMyDaq
    properties (Constant)
        NAME = "myDAQ1"
        CHANNEL = "ao0"
        TYPE = "Voltage"
    end
    properties
        funcAttenVolt
        virtualObject
    end
    properties
        lastAttenuation
    end
    methods
        function obj = Device_ATTENniMyDaq(appStruct)
            obj.funcAttenVolt = appStruct.funcAttenVolt;
            obj.virtualObject = daq("ni");
            addoutput(obj.virtualObject, obj.NAME, obj.CHANNEL, obj.TYPE);
            obj = setAttenuation(obj,0);
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