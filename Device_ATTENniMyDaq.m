classdef Device_ATTENniMyDaq
    properties (Constant)
        name = "myDAQ1"
        channel = "ao0"
        type = "Voltage"
    end
    properties
        funcAttenVolt
        virtualObject
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

            try
                %disp(atten)
                minAttenuation = min(obj.xData);
                maxAttenuation = max(obj.xData);
                if ~((attenuation >= minAttenuation && attenuation <= maxAttenuation) || attenuation == 0)
                    minAttenuationStr = num2str(minAttenuation);
                    maxAttenuationStr = num2str(maxAttenuation);
                    range = [];
                    errorMessage = 
                    error(errorMessage);
                else
                    
                     %obj.
                end
            catch ME
                fig = uifigure;
                uialert(fig,ME.message,'Wrong attenuation');
            end
        end
        function obj = deleteVirtualObject(obj)
            flush(obj.virtualObject);
            delete(obj.virtualObject);
        end
    end
end