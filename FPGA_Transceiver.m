classdef Transceiver
    properties (Constant)
        deviceType = "Трансивер"
        nameCriteria1 = "Выходная мощность, дБм"
        nameCriteria2 = "bit-error-rate (BER)"
        berMax = 10^(-10);
    end
    properties %specifications by user
        boardNumber
        designation
        serialNumber
        comment
        inspectorName
        operatingWavelength
        %testMode
    end
    properties
        transNumber
    end
    properties
        tableComponent
        tableTransceiver
        folder
        time
    end
    properties
        link
        outputPower
        inputPower10 % 10 значит линк 1 -> 0
        inputPower01 % 01 значит линк 0 -> 1
        ber
        timeBer
    end
    properties
        valueCriteria1
        valueCriteria2
    end
    methods
        function obj = Transceiver(app)
            obj.boardNumber = app.BoardnumberEditField.Value;
            obj.designation = app.DesignationEditField.Value;
            obj.serialNumber = app.SerialnumberEditField.Value;
            obj.comment = app.CommentEditField.Value;
            obj.inspectorName = app.InspectornameEditField.Value;
            obj.operatingWavelength = app.OperatingwlEditField.Value;
            %obj.testMode = app.TestmodeDropDown.Value;
            
            if app.tableComponent == "не выбрана" || app.tableTransceiver == "не выбрана"
                error('Не все таблицы добавлены');
            else
                obj.tableComponent = app.tableComponent;
                obj.tableTransceiver = app.tableTransceiver;
            end
            
            obj.folder = app.folder;
            obj.time = app.time;
            
            obj.link = app.link;
            obj.outputPower = app.OutputpowerEditField.Value;
            obj.inputPower10 = app.Inputpowerlink10EditField.Value;
            obj.inputPower01 = app.Inputpowerlink01EditField.Value;
            obj.ber = app.ber;
            if obj.ber > obj.berMax
                obj.ber = ['WARNING ' num2str(obj.ber)];
            end
            obj.timeBer = app.TimefortestEditField.Value;
                
            obj.valueCriteria1 = obj.outputPower;
            obj.valueCriteria2 = obj.ber;
        end
        function obj = saveTable(obj)
            rowNames = readcell(obj.tableTransceiver,'Sheet','Sample');
            rowNames = rowNames(:,1);
            
            rowArray = {obj.boardNumber;obj.deviceType;...
                obj.designation;obj.serialNumber;...
                obj.comment;obj.inspectorName;...
                obj.operatingWavelength;...
                obj.link;obj.outputPower;...
                obj.inputPower10;obj.inputPower01;...
                obj.ber;...
                };
            
            sheetName = createFilename('TR',obj.time);
            
            s1 = obj.boardNumber;
            s2 = obj.designation;
            s3 = obj.serialNumber;
            tableName = ['B' s1 '_' s2 '_' s3];
            
            numRow = table(rowArray,'RowNames',rowNames);
            writetable(numRow,[obj.folder tableName '.xlsx'],'Sheet',sheetName,...
                'WriteVariableNames',false,'WriteRowNames',true,...
                'WriteMode','append','AutoFitWidth',false);%'UseExcel',true
            
            appendTableComponent(obj);
        end
    end
end