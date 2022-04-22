classdef LoadDriver
    properties (Constant)
        deviceType = "Имитатор нагрузки"
        serialNumber = "-"
        nameCriteria1 = "Смещение диапазона";
        nameCriteria2 = "Значение записано в EEPROM";
        isInEEPROM = "нет"
    end
    properties
        boardNumber % user
        designation
        comment % user
        inspectorName % user
    end
    properties
        offsetHighRange % user
        outputCurrent % calc from voltage
        voltage % user
        dac % table
        LDnumber
    end
    properties
        tableComponent
        tableLoadDriver
        folder
        time
    end
    properties
        valueCriteria1
        valueCriteria2
    end
    methods
        function obj = LoadDriver(app)
            obj.boardNumber = app.BoardnumberEditField.Value;
            obj.comment = app.CommentEditField.Value;
            obj.inspectorName = app.InspectornameEditField.Value;
            
            obj.offsetHighRange = app.LDDN_OFFSET_EditField.Value;
            
            if app.tableComponent == "не выбрана" || app.tableLoadDriver == "не выбрана"
                error('Не все таблицы добавлены');
            else
                obj.tableComponent = app.tableComponent;
                obj.tableLoadDriver = app.tableLoadDriver;
            end
            
            obj.folder = app.folder;
            obj.time = app.time;
            
            obj.dac = app.dac;
            obj.voltage = app.voltage;
            obj.outputCurrent = obj.voltage / 0.34; %0.34 Ом сопротивление нагрузки
            obj.designation = ['LoadDriver_' app.LDnumber];
        end
        function saveTable(obj)
            rowNames = readcell(obj.tableLoadDriver,'Sheet','Sample');
            rowNames = rowNames(:,1);
            
            sheetName = createFilename('Ld',obj.time);
            
            s1 = obj.boardNumber;
            s2 = obj.designation;
            tableName = ['B' s1 '_' s2];
            
            rowArray = {obj.boardNumber;obj.deviceType;...
                obj.comment;obj.inspectorName;...
                obj.isInEEPROM;...
                obj.offsetHighRange;obj.outputCurrent;...
                obj.voltage;obj.dac};
            
            tableForSave = table(rowArray,'RowNames',rowNames);
            writetable(tableForSave,[obj.folder tableName '.xlsx'],'Sheet',sheetName,...
                'WriteVariableNames',false,'WriteRowNames',true,...
                'WriteMode','append','AutoFitWidth',false);%'UseExcel',true
            
            obj.valueCriteria1 = obj.offsetHighRange;
            obj.valueCriteria2 = obj.isInEEPROM;
            
            appendTableComponent(obj);
        end
    end
end