classdef FPGA_LaserDiode < FPGA_Component
    properties (Constant)
        deviceTypeConst = "Laser diode"
    end
    properties
        operatingWavelength_nm % from UI
        offsetHighRange % from UI (FPGA)
        index % = zero at start
        DAC % from UI
        outputPower % from OPM or UI
    end
    properties
        tableName
    end
    methods
        function obj = FPGA_LaserDiode(appStruct)
            obj = obj@FPGA_Component(appStruct);
            obj.operatingWavelength_nm = appStruct.operatingWavelength_nm;
            obj.deviceType = obj.deviceTypeConst;
            obj.index = 0;
        end
        function obj = addOffsetHighRange(obj,offsetHighRangeNum)
            obj.offsetHighRange = offsetHighRangeNum;
        end
        function obj = addDACandOutputPower(obj,DAC,outputPower)
            obj.index = obj.index + 1;
            obj.DAC(obj.index) = DAC;
            obj.outputPower(obj.index) = outputPower;
        end
        function obj = setCriterias(obj)
            ind = find(obj.DAC == 1024);
            obj.criteriaNames(1) = "Output power, dBm";
            obj.criteriaValues(1) = obj.outputPower(ind);
            obj.criteriaNames(2) = "DAC";
            obj.criteriaValues(2) = obj.DAC(ind);
        end
        function saveTables(obj)
            rowNames = readcell(obj.tableSamplePath,'Sheet','Sample');
            rowNames = rowNames(:,1);
            s1 = obj.boardNumber;
            s2 = obj.designation;
            s3 = createFilename(obj.time);
            obj.tableName = ['B' s1 '_' s2 '_' s3];
            sheetName = obj.tableName;%createFilename(obj.time,'LD');
            arrayForSave = {obj.boardNumber;obj.deviceType;obj.designation;...
                obj.serialNumber;obj.comment;obj.inspectorName;...
                obj.operatingWavelength_nm,obj.offsetHighRange,...
                obj.outputPower;obj.DAC};
            tableForSave = table(arrayForSave,'RowNames',rowNames);
            writetable(tableForSave,[obj.folder obj.tableName '.xlsx'],'Sheet',sheetName,...
                'WriteVariableNames',false,'WriteRowNames',true,...
                'WriteMode','append','AutoFitWidth',false);
            appendTableComponents(obj);
        end
    end
end