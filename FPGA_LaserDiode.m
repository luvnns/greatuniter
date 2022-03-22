classdef LaserDiode
    properties (Constant)
        deviceType = "Лазерный диод"
        nameCriteria1 = "Выходная мощность, дБм"
        nameCriteria2 = "Ток, подаваемый на диод"
    end
    properties
        boardNumber
        designation
        serialNumber
        comment
        inspectorName
        operatingWavelength
    end
    properties
        tableComponent
        tableLaserDiode
        folder
        time
    end
    properties
        offset
        outputPower
        current
        valueCriteria1
        valueCriteria2
    end
    methods
        function obj = LaserDiode(app)
            obj.boardNumber = app.BoardnumberEditField.Value;
            obj.designation = app.DesignationEditField.Value;
            obj.serialNumber = app.SerialnumberEditField.Value;
            obj.comment = app.CommentEditField.Value;
            obj.inspectorName = app.InspectornameEditField.Value;
            obj.operatingWavelength = app.OperatingwlEditField.Value;
            
            obj.offset = app.LDDN_OFFSET_HIGH_RANGEEditField.Value;
            obj.outputPower = app.PoutputEditField.Value;
            obj.current = app.LDDN_CURRENTEditField.Value;
            
            if app.tableComponent == "не выбрана" || app.tableLaserDiode == "не выбрана"
                error('Не все таблицы добавлены');
            else
                obj.tableComponent = app.tableComponent;
                obj.tableLaserDiode = app.tableLaserDiode;
            end
            
            obj.folder = app.folder;
            obj.time = app.time;
        end
        function obj = saveTable(obj)
            rowNames = readcell(obj.tableLaserDiode,'Sheet','Sample');
            rowNames = rowNames(:,1);
            
            rowArray = {obj.boardNumber;obj.deviceType;...
                obj.designation;obj.serialNumber;...
                obj.comment;obj.inspectorName;...
                obj.operatingWavelength;...
                obj.offset;obj.outputPower;...
                obj.current};
            
            sheetName = createFilename('LD',obj.time);
            
            s1 = obj.boardNumber;
            s2 = obj.designation;
            s3 = obj.serialNumber;
            tableName = ['B' s1 '_' s2 '_' s3];
            
            numRow = table(rowArray,'RowNames',rowNames);
            writetable(numRow,[obj.folder tableName '.xlsx'],'Sheet',sheetName,...
                'WriteVariableNames',false,'WriteRowNames',true,...
                'WriteMode','append','AutoFitWidth',false);%'UseExcel',true
            
            obj.valueCriteria1 = obj.outputPower;
            obj.valueCriteria2 = obj.current;
            
            appendTableComponent(obj);
        end
    end
end