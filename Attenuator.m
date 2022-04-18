classdef Attenuator
    properties (Constant)
        deviceType = "Variable Optical Attenuator"
        nameCriteria1 = "Attenuation at 0 V, dB"
        nameCriteria2 = "Attenuation at 3 V, dB"
    end
    properties
        boardNumber
        designation
        serialNumber
        comment
        inspectorName
        testMode
    end
    properties
        fpgaName
    end
    properties
        tableComponent
        tableAttenuator
        folder
        time
    end
    properties
        powerInput
        powerOutput
        coeffMeasure
        coeffPassport
        voltage
        dac
        timeDelay
        i
    end
    properties
        valueCriteria1
        valueCriteria2
    end
    % Методы, включая конструктор класса
    methods
        % Конструктор класса
        function obj = Attenuator(app)
            obj.boardNumber = app.BoardnumberEditField.Value;
            obj.designation = app.DesignationEditField.Value;
            obj.serialNumber = app.SerialnumberEditField.Value;
            obj.comment = app.CommentEditField.Value;
            obj.inspectorName = app.InspectornameEditField.Value;
            obj.testMode = app.TestmodeDropDown.Value;
            
            obj.folder = app.folder;
            obj.time = app.time;
            
            obj.designation = char(obj.designation);
            attenNum = str2double(obj.designation(end));
            if attenNum == 1
                obj.fpgaName = 'A1_ATTEN_L1';
            elseif attenNum == 2
                obj.fpgaName = 'A2_ATTEN_L2';
            elseif attenNum == 3
                obj.fpgaName = 'A3_ATTEN_TEST_L1_TO_L2';
            elseif attenNum == 4
                obj.fpgaName = 'A4_ATTEN_TEST_L2_TO_L1';
            end
            if app.tableComponent == "не выбрана" || app.tableAttenuator == "не выбрана"
                error('Не все таблицы добавлены');
            else
                obj.tableComponent = app.tableComponent;
                obj.tableAttenuator = app.tableAttenuator;
                numRows = readtable(obj.tableAttenuator,'Sheet','Sample',...
                    'ReadVariableNames',false,'ReadRowNames',true);
                obj.dac = numRows{'Значение на ЦАП',:};
                obj.voltage = obj.dac * 5 / (2^16 - 1);
                obj.timeDelay = numRows{'Время задержки, с',:};
                obj.coeffPassport = zeros(1,length(obj.dac));
                obj.i = 1;
            end
        end
        function obj = savePowerOutput(obj,powerOutput)
            obj.powerOutput(obj.i) = powerOutput;
            obj.i = obj.i + 1;
        end
        function obj = savePowerInput(obj,powerInput)
            obj.powerInput = powerInput;
            obj.coeffMeasure = obj.powerInput - obj.powerOutput;
                        
            obj.valueCriteria1 = obj.coeffMeasure(2);
            obj.valueCriteria2 = obj.coeffMeasure(1);
        end
        function saveTables(obj)
            rowNames = readcell(obj.tableAttenuator,'Sheet','Sample');
            rowNames = rowNames(:,1);
            
            sheetName = createFilename('AT',obj.time);
            
            s1 = obj.boardNumber;
            s2 = obj.designation;
            s3 = obj.serialNumber;
            tableName = ['B' s1 '_' s2 '_' s3];
            
            rowArray = {obj.boardNumber;obj.deviceType;obj.designation;...
                obj.serialNumber;obj.comment;obj.inspectorName;...
                obj.powerInput;obj.powerOutput;obj.coeffMeasure;...
                obj.coeffPassport;obj.voltage;obj.dac;obj.timeDelay};
            
            tableForSave = table(rowArray,'RowNames',rowNames);
            writetable(tableForSave,[obj.folder tableName '.xlsx'],'Sheet',sheetName,...
                'WriteVariableNames',false,'WriteRowNames',true,...
                'WriteMode','append','AutoFitWidth',false);%'UseExcel',true
            
            appendTableComponent(obj);
        end
    end
end