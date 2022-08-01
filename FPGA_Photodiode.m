classdef Photodiode
    properties (Constant)
        deviceType = "ФПУ"
    end
    properties
        boardNumber
        designation
        serialNumber
        comment
        inspectorName
    end
    properties
        infostr
        fpgaName
        tableComponent
        tablePhotodiode
        folder
        time
    end
    properties
        resistor
        voltage
        wavelength %table
        loss %table
        responsivityPassport
        responsivityMeasure % вычисляется между первыми двумя измерениями,
        % но можно измерить больше и в экселе посчитать по другим измерениям
        %coefficient
        powerFPGA % adc
        current
        powerOPM % input power
        sourcesState
        numberMeasurement
    end
    properties
        nameCriteria1
        valueCriteria1
        nameCriteria2
        valueCriteria2
    end
    methods
        function obj = Photodiode(app)
            obj.infostr = app.tableArrayStr;
            
            obj.boardNumber = app.BoardnumberEditField.Value;
            obj.designation = obj.infostr{1,'Designition'};
            obj.designation = obj.designation{1};
            obj.serialNumber = obj.infostr{1,'SerialNumber'};
            %obj.serialNumber = num2str(obj.serialNumber);
            %disp(obj.serialNumber)
            obj.serialNumber = obj.serialNumber{1};
            obj.comment = app.CommentEditField.Value;
            obj.inspectorName = app.InspectornameEditField.Value;
            
            obj.numberMeasurement = 1;
            
            obj.wavelength = obj.infostr{1,'OperatingWavelength'};
            obj.fpgaName = obj.infostr{1,'FPGAAddress'};
            obj.loss = obj.infostr{1,'Loss'};
            obj.resistor = obj.infostr{1,'Resistor'};
            
%             obj.powerFPGA(obj.numberMeasurement) = app.meanPowerFPGA;
%             obj.powerOPM(obj.numberMeasurement) = app.meanPowerOPM;
            %obj.coefficient = obj.current/obj.powerFPGA;
            
            if app.tableComponent == "не выбрана" || app.tablePhotodiode == "не выбрана"
                error('Не все таблицы добавлены');
            else
                obj.tableComponent = app.tableComponent;
                obj.tablePhotodiode = app.tablePhotodiode;
            end
            
            obj.folder = app.folder;
            obj.time = app.time;
        end
        function obj = addMeasurement(obj,app)
            obj.sourcesState{obj.numberMeasurement} = app.SourcesEditField.Value;
            obj.powerFPGA(obj.numberMeasurement) = app.meanPowerFPGA;
            
            if isequal(obj.fpgaName,'ADC1CH5_VD3_Pin_L1_1') || ...
                    isequal(obj.fpgaName,'ADC1CH4_VD4_Pin_L2_1') || ...
                    isequal(obj.fpgaName,'ADC2CH5_VD9_Pin_L1_2') || ...
                    isequal(obj.fpgaName,'ADC2CH4_VD10_Pin_L2_2')
                obj.voltage(obj.numberMeasurement) = ...
                    obj.powerFPGA(obj.numberMeasurement)*4.096*2/(2^18-1);
                obj.current(obj.numberMeasurement) = ...
                    obj.voltage(obj.numberMeasurement)/(obj.resistor*2)*10^6;
            else
                obj.voltage(obj.numberMeasurement) = ...
                    obj.powerFPGA(obj.numberMeasurement)*4.096/(2^18-1);
                obj.current(obj.numberMeasurement) = ...
                    obj.voltage(obj.numberMeasurement)/obj.resistor*10^6;
            end
            obj.powerOPM(obj.numberMeasurement) = dBm2mkW(app.meanPowerOPM);
            %%%
            
            obj.numberMeasurement = obj.numberMeasurement + 1;
        end
        function saveTable(obj)
            deltaCurrent = obj.current(2) - obj.current(1);
            deltaPowerOPM = obj.powerOPM(2) - obj.powerOPM(1);
            obj.responsivityMeasure = deltaCurrent / deltaPowerOPM;
            
            rowNames = readcell(obj.tablePhotodiode,'Sheet','Sample');
            rowNames = rowNames(:,1);
            
            sheetName = createFilename('VD',obj.time);
            
            s1 = obj.boardNumber;
            s2 = obj.designation;
            s3 = obj.serialNumber;
            tableName = ['B' s1 '_' s2 '_' s3];
            
            rowArray = {obj.boardNumber;obj.deviceType;obj.designation;...
                obj.serialNumber;obj.comment;obj.inspectorName;...
                obj.wavelength;obj.loss;obj.responsivityPassport;...
                obj.responsivityMeasure;obj.resistor;...
                obj.powerFPGA;obj.current;obj.powerOPM;obj.sourcesState};
            
            tableForSave = table(rowArray,'RowNames',rowNames);
            writetable(tableForSave,[obj.folder tableName '.xlsx'],'Sheet',sheetName,...
                'WriteVariableNames',false,'WriteRowNames',true,...
                'WriteMode','append','AutoFitWidth',false);%'UseExcel',true
            
            obj.nameCriteria1 = "Чувствительность, А/Вт";
            obj.valueCriteria1 = obj.responsivityMeasure;
            obj.nameCriteria2 = "Темновой ток, мкА";
            obj.valueCriteria2 = obj.current(1);
            
            appendTableComponent(obj);
        end
    end
end