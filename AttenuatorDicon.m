classdef AttenuatorDicon
    properties
        xData
        yData
        virtualObject
        attenuation
    end
    methods
        function obj = AttenuatorDicon(app)
            dicon = readmatrix(app.DiconpassportTextArea.Value{1});
            voltageV = dicon(:,1);
            attenuationdBm = dicon(:,2);
            [obj.xData, obj.yData] = prepareCurveData( attenuationdBm, voltageV );
            obj.virtualObject = daq("ni");
            addoutput(obj.virtualObject, "myDAQ1", "ao0", "Voltage");
            obj = setAttenuation(obj,0);
        end
        function obj = setAttenuation(obj,atten) %obj = 
            try
                %disp(atten)
                minAttenuation = min(obj.xData);
                maxAttenuation = max(obj.xData);
                if ~((atten >= minAttenuation && atten <= maxAttenuation) || atten == 0)
                    minAttenuationStr = num2str(minAttenuation);
                    maxAttenuationStr = num2str(maxAttenuation);
                    range = ['from ' minAttenuationStr ' to ' maxAttenuationStr];
                    errorMessage = ['Attenuation must be in range ' range];
                    error(errorMessage);
                else
                    % Set up fittype and options.
                    ft = 'linearinterp';
                    % Fit model to data.
                    [fitresult, gof] = fit( obj.xData, obj.yData, ft, 'Normalize', 'on' );
                    % fitresult - функция, на вход принимает аттенюацию, на выходе
                    % - напряжение
                    output_ao0 = fitresult(atten);
                    write(obj.virtualObject,output_ao0);
                    obj.attenuation = atten; %obj.
                end
            catch ME
                fig = uifigure;
                uialert(fig,ME.message,'Wrong attenuation');
            end
        end
        function obj = deleteVirtualObject(obj)
            setZeroAttenuation(obj);
            flush(obj.virtualObject);
            delete(obj.virtualObject);
        end
    end
end