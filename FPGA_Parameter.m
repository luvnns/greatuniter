classdef FPGA_Parameter < FPGA_Component
    properties (Constant)
        deviceTypeConst = "Electric parameter"
    end
    properties
        cellOtherParameter
        tableName
    end
    methods
        function obj = FPGA_Parameter(appStruct)
            obj = obj@FPGA_Component(appStruct);
            obj.deviceType = obj.deviceTypeConst;
        end
        function obj = setParameters(obj,tempAndElectricStruct,params)
            header = {obj.boardNumber;obj.comment;obj.inspectorName};
            header(:,2:3) = {'','';'','';'',''};
            tempOut = tempAndElectricStruct.tempOut;
            tempFPGA = tempAndElectricStruct.tempFPGA;
            tempLD = tempAndElectricStruct.tempLD;
            voltage = tempAndElectricStruct.voltage;
            current = tempAndElectricStruct.current;
            data = {tempOut;tempFPGA;tempLD;voltage;current};
            data(:,2:3) = {'','';'','';'','';'','';'','';'','';'',''};
            obj.cellOtherParameter = [header; data; params];
        end
        function obj = setCriterias(obj,name,value)
            obj.criteriaNames(1) = name;
            obj.criteriaValues(1) = value;
            %obj.criteriaNames(2) = ;
            %obj.criteriaValues(2) = ;
        end
        function saveTables(obj)
            rowNames = readcell(obj.tableSamplePath,'Sheet','Sample');
            rowNames = rowNames(:,1);
            s1 = obj.boardNumber;
            s2 = obj.designation;
            s3 = createFilename(obj.time);
            obj.tableName = ['B' s1 '_' s2 '_' s3];
            sheetName = obj.tableName; %createFilename(obj.time,'AT');
            arrayForSave = obj.cellOtherParameter;
            tableForSave = table(arrayForSave,'RowNames',rowNames);
            writetable(tableForSave,[obj.folder obj.tableName '.xlsx'],'Sheet',sheetName,...
                'WriteVariableNames',false,'WriteRowNames',true,...
                'WriteMode','append','AutoFitWidth',false);

            tableForAppend = tableForSave(3:end,:);
            criteriasNames = tableForAppend.Properties.RowNames;
            for i = 1:height(tableForAppend)
                name = criteriasNames{i};
                cellValue = tableForAppend{i,1};
                value = cellValue{1};
                obj = setCriterias(obj,name,value);
                appendTableComponents(obj);
            end
        end
    end
end