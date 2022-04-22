classdef FPGA_LoadDriver < FPGA_Component
    properties (Constant)
        deviceTypeConst = "Load driver"
        DACrowName = 'DAC'
        resistance_Ohm = 0.34
    end
    properties
        offsetHighRangeFromEEPROM % from UI (FPGA)
        index % = zero at start
        maxIndex
        current_mA % calc I = U/R at the end
        voltage_mV % from UI
        DAC % from table
    end
    properties
        tableName
    end
    methods
        function obj = FPGA_LoadDriver(appStruct)
            obj = obj@FPGA_Component(appStruct);
            obj.deviceType = obj.deviceTypeConst;
            tableSample = readtable(obj.tableSamplePath,'Sheet','Sample',...
                    'ReadVariableNames',false,'ReadRowNames',true);
            obj.DAC = tableSample{obj.DACrowName,:};
            obj.maxIndex = length(obj.DAC);
            obj = clearTest(obj);
        end
        function obj = clearTest(obj)
            obj.index = 0;
            obj.current_mA = zeros(1,obj.maxIndex);
            obj.voltage_mV = zeros(1,obj.maxIndex);
        end
        function obj = addOffsetHighRangeFromEEPROM(obj,offsetHighRangeNum)
            obj.offsetHighRangeFromEEPROM = offsetHighRangeNum;
        end
        function DAC = nextDAC(obj)
            obj.index = obj.index + 1;
            DAC = obj.DAC(obj.index);
        end
        function obj = addVoltageAndCalcCurrent(obj,voltage_mV)
            obj.index = obj.index + 1;
            obj.voltage_mV(obj.index) = voltage_mV;
            obj.current_mA(obj.index) = obj.voltage_mV(obj.index) / obj.resistance_Ohm;
        end
        function obj = setCriterias(obj)
            obj.criteriaNames(1) = "Offset high range from EEPROM";
            obj.criteriaValues(1) = obj.offsetHighRangeFromEEPROM;
            %obj.criteriaNames(2) = "";
            %obj.criteriaValues(2) = obj.DAC(ind);
        end
        function saveTables(obj)
            rowNames = readcell(obj.tableSamplePath,'Sheet','Sample');
            rowNames = rowNames(:,1);
            s1 = obj.boardNumber;
            s2 = obj.designation;
            s3 = createFilename(obj.time);
            obj.tableName = ['B' s1 '_' s2 '_' s3];
            sheetName = obj.tableName;%createFilename(obj.time,'Ld');
            arrayForSave = {obj.boardNumber;obj.deviceType;obj.designation;...
                obj.serialNumber;obj.comment;obj.inspectorName;...
                obj.offsetHighRangeFromEEPROM,obj.current_mA...
                obj.voltage_mV;obj.DAC};
            tableForSave = table(arrayForSave,'RowNames',rowNames);
            writetable(tableForSave,[obj.folder obj.tableName '.xlsx'],'Sheet',sheetName,...
                'WriteVariableNames',false,'WriteRowNames',true,...
                'WriteMode','append','AutoFitWidth',false);
            appendTableComponents(obj);
        end
    end
end