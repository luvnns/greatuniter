classdef Device_SWITCHosaEdfaTwoLines
    properties (Constant)
        BAUDRATE = 57600
        REQUEST_SWITCH_STATE = "state"
        REQUEST_SWITCH_OSA = "switch=osa"
        REQUEST_SWITCH_EDFA_FIRST_LINE = "switch=line1"
        REQUEST_SWITCH_EDFA_SECOND_LINE = "switch=line2"
        RESPONSE_SWITCH_OSA = string(['osa',char(13)])
        RESPONSE_SWITCH_EDFA_FIRST_LINE = string(['line1',char(13)])
        RESPONSE_SWITCH_EDFA_SECOND_LINE = string(['line2',char(13)])
    end
    properties %for constructor
        serialPort
    end
    properties
        virtualObject
        switchState
        lastResponse
        infoString
    end
    methods (Access = public)
        function obj = Device_SWITCHosaEdfaTwoLines(appStruct)
            obj.serialPort = appStruct.SerialportDropDown;
            obj.virtualObject = serialport(obj.serialPort,obj.BAUDRATE);
            obj = requestSwitchState(obj);
        end
        function obj = requestSwitchState(obj)
            requestCommand = obj.REQUEST_SWITCH_STATE;
            writeline(obj.virtualObject,requestCommand);
            obj = readSwitchState(obj);
        end
        function obj = switchSignalTo(obj,OSAorEDFAstring)
            % OSAorEDFAstring = "OSA", "EDFAFirstLine" or "EDFASecondLine"
            if OSAorEDFAstring == "OSA"
                requestCommand = obj.REQUEST_SWITCH_OSA;
            elseif OSAorEDFAstring == "EDFAFirstLine"
                requestCommand = obj.REQUEST_SWITCH_EDFA_FIRST_LINE;
            elseif OSAorEDFAstring == "EDFASecondLine"
                requestCommand = obj.REQUEST_SWITCH_EDFA_SECOND_LINE;
            end
            writeline(obj.virtualObject,requestCommand);
            obj = readSwitchState(obj);
        end
        function obj = sendCommand(obj,requestCommand)
            writeline(obj.virtualObject,requestCommand);
            obj = readSwitchState(obj);
        end
        function obj = deleteVirtualObject(obj)
            delete(obj.virtualObject);
        end
    end
    methods (Access = private, Hidden)
        function obj = readSwitchState(obj)
            obj.lastResponse = readline(obj.virtualObject);
            if obj.lastResponse == obj.RESPONSE_SWITCH_OSA
                obj.switchState = "OSA";
                obj.infoString = "Switch state OSA";
            elseif obj.lastResponse == obj.RESPONSE_SWITCH_EDFA_FIRST_LINE
                obj.switchState = "EDFAFirstLine";
                obj.infoString = "Switch state EDFA first line";
            elseif obj.lastResponse == obj.RESPONSE_SWITCH_EDFA_SECOND_LINE
                obj.switchState = "EDFASecondLine";
                obj.infoString = "Switch state EDFA second line";
            else
                obj.switchState = "unknown";
                obj.infoString = "Switch state unknown";
            end
        end
    end
end