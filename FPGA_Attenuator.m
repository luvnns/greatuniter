classdef FPGA_Attenuator < FPGA_Component
    properties (Constant)
        factorToGetVoltage =  5 / (2^16 - 1)
        deviceTypeConst = "Variable Optical Attenuator"
        DACrowName = 'DAC'
        pauseTimeRowName = 'PauseTime_s'
    end
    properties
        index % = zero at start
        pauseTime % from table
        DAC % from table
        voltage % calc
        inputPower % from OPM or UI
        outputPower % from OPM or UI
        attenuationCoefficientMeasure % calc
        attenuationCoefficientDatasheet % usually empty
    end
    properties
        tableName
    end
    methods
        function obj = FPGA_Attenuator(appStruct)
            obj = obj@FPGA_Component(appStruct);
            obj.deviceType = obj.deviceTypeConst;
            obj.index = 0;
            tableSample = readtable(obj.tableSamplePath,'Sheet','Sample',...
                    'ReadVariableNames',false,'ReadRowNames',true);
            obj.pauseTime = tableSample{obj.pauseTimeRowName,:};
            obj.DAC = tableSample{obj.DACrowName,:};
            obj.voltage = obj.DAC * obj.factorToGetVoltage;
            len = length(obj.DAC);
            obj.outputPower = zeros(1,len);
            obj.attenuationCoefficientMeasure = zeros(1,len);
            obj.attenuationCoefficientDatasheet = zeros(1,len);
        end
        function obj = addOutputPower(obj,outputPower)
            obj.index = obj.index + 1;
            obj.outputPower(obj.index) = outputPower;
        end
        function obj = addInputPower(obj,inputPower)
            obj.inputPower = inputPower;
        end
        function obj = calculateAttenuation(obj)
            obj.attenuationCoefficientMeasure = obj.inputPower - obj.outputPower;
        end
        function obj = setCriterias(obj)
            obj.criteriaNames(1) = "Attenuation at 0 V, dB";
            ind = find(obj.voltage == 0);
            obj.criteriaValues(1) = obj.attenuationCoefficientMeasure(ind);
            obj.criteriaNames(2) = "Attenuation at 3 V, dB";
            ind = find(obj.voltage == 3);
            obj.criteriaValues(2) = obj.attenuationCoefficientMeasure(ind);
        end
        function saveTables(obj)
            obj = setCriterias(obj);
            rowNames = readcell(obj.tableSamplePath,'Sheet','Sample');
            rowNames = rowNames(:,1);
            s1 = obj.boardNumber;
            s2 = obj.designation;
            s3 = createFilename(obj.time);
            obj.tableName = ['B' s1 '_' s2 '_' s3];
            sheetName = obj.tableName; %createFilename(obj.time,'AT');
            arrayForSave = {obj.boardNumber;obj.deviceType;obj.designation;...
                obj.FPGAaddressName,obj.serialNumber;obj.comment;obj.inspectorName;...
                obj.inputPower;obj.outputPower;obj.attenuationCoefficientMeasure;...
                obj.attenuationCoefficientDatasheet;obj.voltage;obj.DAC;obj.pauseTime};
            tableForSave = table(arrayForSave,'RowNames',rowNames);
            writetable(tableForSave,[obj.folder obj.tableName '.xlsx'],'Sheet',sheetName,...
                'WriteVariableNames',false,'WriteRowNames',true,...
                'WriteMode','append','AutoFitWidth',false);
            appendTableComponents(obj);
        end
    end
end