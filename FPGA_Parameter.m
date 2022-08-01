classdef OtherParameter
    properties (Constant)
        deviceType = "Общие проверки"
        designation = "-"
        serialNumber = "-"
        nameCriteria2 = "-"
        valueCriteria2 = "-"
    end
    properties
        boardNumber
        comment
        inspectorName
        cellOtherParameter
    end
    properties
        tableComponent
        tableOtherParameter
        folder
        time
    end
    properties
        nameCriteria1
        valueCriteria1
    end
    methods
        function obj = OtherParameter(app)
            obj.boardNumber = app.BoardnumberEditField.Value;
            obj.comment = app.CommentEditField.Value;
            obj.inspectorName = app.InspectornameEditField.Value;
            header = {obj.boardNumber;obj.comment;obj.inspectorName};
            header(:,2:3) = {'','';'','';'',''};
            ethernet = app.EthernetDropDown.Value;
            tempOut = app.TemperatureoutsideEditField.Value;
            tempFPGA = app.TemperaturefpgaEditField.Value;
            tempLD = app.TemperaturefpgaEditField.Value;
            voltage = app.VoltageEditField.Value;
            current = app.CurrentEditField.Value;
            currentMax = app.CurrentmaxEditField.Value;
            data = {ethernet;tempOut;tempFPGA;tempLD;voltage;current;currentMax};
            data(:,2:3) = {'','';'','';'','';'','';'','';'','';'',''};
            paramFromBoard = app.paramFromBoard;
            obj.cellOtherParameter = [header; data; paramFromBoard];
            
            if app.tableComponent == "не выбрана" || app.tableOtherParameter == "не выбрана"
                error('Не все таблицы добавлены');
            else
                obj.tableComponent = app.tableComponent;
                obj.tableOtherParameter = app.tableOtherParameter;
            end
            obj.folder = app.folder;
            obj.time = app.time;
        end
        function obj = saveTable(obj)
            rowNames = readcell(obj.tableOtherParameter,'Sheet','Sample');
            rowNames = rowNames(:,1);
            disp(rowNames)
            
            sheetName = createFilename('OP',obj.time);
            
            s1 = obj.boardNumber;
            s2 = 'OtherParams';
            tableName = ['B' s1 '_' s2];
            tableForSave = table(obj.cellOtherParameter,'RowNames',rowNames);
            writetable(tableForSave,[obj.folder tableName '.xlsx'],'Sheet',sheetName,...
                'WriteVariableNames',false,'WriteRowNames',true,...
                'WriteMode','append','AutoFitWidth',false);%'UseExcel',true
            
            tableForAppend = tableForSave(4:end,:);%%%%
            
            for i = 1:height(tableForAppend)
                obj.nameCriteria1 = tableForAppend.Properties.RowNames{i};
                value = tableForAppend{i,1};
                obj.valueCriteria1 = value{1};
                appendTableComponent(obj);
            end
        end
    end
end