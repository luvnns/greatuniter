classdef FPGA_Component
    properties
        time
        folder
        tableComponentsPath
        tableSamplePath
        boardNumber
        deviceType
        designation
        FPGAaddressName
        serialNumber
        comment
        inspectorName
        criteriaNames
        criteriaValues
    end
    methods
        function obj = FPGA_Component(appStruct)
            obj.time = appStruct.time;
            obj.folder = appStruct.folder;
            obj.tableComponentsPath = appStruct.tableComponentsPath;
            obj.tableSamplePath = appStruct.tableSamplePath;
            obj.boardNumber = appStruct.boardNumber;
            obj.deviceType = "";
            obj.designation = appStruct.designation;
            obj.serialNumber = appStruct.serialNumber;
            obj.comment = appStruct.comment;
            obj.inspectorName = appStruct.inspectorName;
            obj.criteriaNames = strings(1,2);
            obj.criteriaValues = zeros(1,2);
        end
        function appendTableComponents(obj)
            testTime = datestr(obj.time,'hh:MM:ss');
            testDate = datestr(obj.time,'DD.mm.YYYY');
            newRow = {obj.boardNumber,obj.deviceType,...
                obj.designation,obj.serialNumber,...
                obj.criteriaNames(1),obj.criteriaValues(1),...
                obj.criteriaNames(2),obj.criteriaValues(2),...
                obj.comment,testTime,testDate,obj.inspectorName};
            writecell(newRow,obj.tableComponentsPath,'Sheet','Sample',...
                'WriteMode','append','AutoFitWidth',false);
        end
    end
end