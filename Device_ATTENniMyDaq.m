classdef Device_ATTENniMyDaq
    properties (Constant)
        NAME = "myDAQ1"
        CHANNEL = "ao0"
        TYPE = "Voltage"
    end
    properties
        matrixAttenVolt
        funcAttenVolt
        virtualObject
    end
    properties
        minAtten
        maxAtten
        lastAttenuation
    end
    methods
        function obj = Device_ATTENniMyDaq(appStruct)
            obj.matrixAttenVolt = appStruct.matrixAttenVolt;
            obj.minAtten = min(obj.matrixAttenVolt(:,1));
            obj.maxAtten = max(obj.matrixAttenVolt(:,1));
            obj.funcAttenVolt = convertMatrixToFunc(obj.matrixAttenVolt);
            obj.virtualObject = daq("ni");
            addoutput(obj.virtualObject, obj.NAME, obj.CHANNEL, obj.TYPE);
            obj = setMaxAttenuation(obj);
        end
        function obj = setAttenuation(obj,attenuation)
            if ( ...
                    (...
                    obj.minAtten <= attenuation && ...
                    attenuation <= obj.maxAtten ...
                    ) || ...
                    attenuation == 0 ...
                )
                output = obj.funcAttenVolt(attenuation);
                write(obj.virtualObject,output);
                obj.lastAttenuation = attenuation;
            end
        end
        function obj = setMaxAttenuation(obj)
            attenuation = obj.maxAtten;
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