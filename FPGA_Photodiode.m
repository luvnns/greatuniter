classdef FPGA_Photodiode < FPGA_Component
    properties (Constant)
        deviceTypeConst = "Photodiode"
        MULTIPLE_COEFFICIENT = 4.096/(2^18-1)*10^6
    end
    properties
        index
        wavelength
        fpgaName
        loss
        resistor
    end
    properties
        responsivityPassport
        responsivityMeasure % вычисляется между первыми двумя измерениями,
        % но можно измерить больше и в экселе посчитать по другим измерениям
        powerFPGA % adc
        current
        powerOPM % input power
        sourcesState
    end
    properties
        tableName
    end
    methods
        function obj = FPGA_Photodiode(appStruct)
            obj = obj@FPGA_Component(appStruct);
            obj.deviceType = obj.deviceTypeConst;
            obj.index = 0;
            obj.wavelength = appStruct.wavelength;%obj.infostr{1,'OperatingWavelength'};
            obj.fpgaName = appStruct.fpgaName;%obj.infostr{1,'FPGAAddress'};
            obj.loss = appStruct.loss;%obj.infostr{1,'Loss'};
            obj.resistor = appStruct.resistor;%obj.infostr{1,'Resistor'};
        end
        function obj = addMeasurement(obj,newMeasurement)
            obj.index = obj.index + 1;
            obj.powerOPM(obj.index) = dbm2w(newMeasurement.meanPowerOPM,'u');
            obj.sourcesState{obj.index} = newMeasurement.sourcesState;
            obj.powerFPGA(obj.index) = newMeasurement.meanPowerFPGA;
            obj.current(obj.index) = obj.powerFPGA(obj.index) * ...
                obj.MULTIPLE_COEFFICIENT / obj.resistor;
        end
        function obj = setCriterias(obj)
            obj.criteriaNames(1) = "Responsivity, A/W";
            deltaCurrent = obj.current(2) - obj.current(1);
            deltaPowerOPM = obj.powerOPM(2) - obj.powerOPM(1);
            obj.responsivityMeasure = deltaCurrent / deltaPowerOPM;
            obj.criteriaValues(1) = obj.responsivityMeasure;
            obj.criteriaNames(2) = "Leakage current, mkA";
            obj.criteriaValues(2) = min(obj.current);
        end
        function saveTable(obj)
            obj = setCriterias(obj);
            rowNames = readcell(obj.tableSamplePath,'Sheet','Sample');
            rowNames = rowNames(:,1);
            s1 = obj.boardNumber;
            s2 = obj.designation;
            s3 = createFilename(obj.time);
            obj.tableName = ['B' s1 '_' s2 '_' s3];
            sheetName = obj.tableName; %createFilename(obj.time,'AT');
            arrayForSave = {obj.boardNumber;obj.deviceType;obj.designation;...
                obj.serialNumber;obj.comment;obj.inspectorName;...
                obj.wavelength;obj.loss;obj.responsivityPassport;...
                obj.responsivityMeasure;obj.resistor;...
                obj.powerFPGA;obj.current;obj.powerOPM;obj.sourcesState};
            tableForSave = table(arrayForSave,'RowNames',rowNames);
            writetable(tableForSave,[obj.folder obj.tableName '.xlsx'],'Sheet',sheetName,...
                'WriteVariableNames',false,'WriteRowNames',true,...
                'WriteMode','append','AutoFitWidth',false);
            appendTableComponents(obj);
        end
    end
end