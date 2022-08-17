classdef FPGA_Transceiver < FPGA_Component
    properties (Constant)
        deviceTypeConst = "Transceiver"
        %berMax = 10^(-10);
    end
    properties
        operatingWavelength
    end
    properties
        outputPower
        risingPower
        fallingPower
        %ber
        %timeBer
    end
    methods
        function obj = FPGA_Transceiver(appStruct)
            obj = obj@FPGA_Component(appStruct);
            obj.deviceType = obj.deviceTypeConst;
            obj.operatingWavelength = appStruct.wavelength;
%             obj.ber = app.ber;
%             if obj.ber > obj.berMax
%                 obj.ber = ['WARNING ' num2str(obj.ber)];
%             end
%             obj.timeBer = app.TimefortestEditField.Value;
        end
        function obj = setPowers(obj, powerStruct)
            obj.outputPower = powerStruct.outputPower;
            obj.risingPower = powerStruct.risingPower;
            obj.fallingPower = powerStruct.fallingPower;
        end
        function obj = setCriterias(obj)
            obj.criteriaNames(1) = "Output power, dBm";
            obj.criteriaValues(1) = obj.outputPower;
            %obj.criteriaNames(2) = "bit-error-rate (BER)";
            %obj.criteriaValues(2) = 'none';
        end
        function obj = saveTable(obj)
            obj = setCriterias(obj);
            rowNames = readcell(obj.tableSamplePath,'Sheet','Sample');
            rowNames = rowNames(:,1);
            s1 = obj.boardNumber;
            s2 = obj.designation;
            s3 = createFilename(obj.time);
            obj.tableName = ['B' s1 '_' s2 '_' s3];
            sheetName = obj.tableName;%createFilename(obj.time,'Ld');
            arrayForSave = {obj.boardNumber;obj.deviceType;obj.designation;...
                obj.serialNumber;obj.comment;obj.inspectorName;...
                obj.operatingWavelength;obj.outputPower;...
                obj.fallingPower;obj.risingPower...
                };
            tableForSave = table(arrayForSave,'RowNames',rowNames);
            writetable(tableForSave,[obj.folder obj.tableName '.xlsx'],'Sheet',sheetName,...
                'WriteVariableNames',false,'WriteRowNames',true,...
                'WriteMode','append','AutoFitWidth',false);
            appendTableComponents(obj);
         end
    end
end