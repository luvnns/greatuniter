classdef Device_SWITCHosaEdfa
    properties (Constant)
        BAUDRATE = 57600
        REQUEST_SWITCH_STATE = "data?;"
        REQUEST_SWITCH_OSA = "003;1;"
        REQUEST_SWITCH_EDFA = "003;0;"
        RESPONSE_SWITCH_OSA = string(['1;1',char(13)])
        RESPONSE_SWITCH_EDFA = string(['0;0',char(13)])
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
        function obj = Device_SWITCHosaEdfa(appStruct)
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
            if OSAorEDFAstring == "OSA"
                requestCommand = obj.REQUEST_SWITCH_OSA;
            elseif OSAorEDFAstring == "EDFA"
                requestCommand = obj.REQUEST_SWITCH_EDFA;
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
            elseif obj.lastResponse == obj.RESPONSE_SWITCH_EDFA
                obj.switchState = "EDFA";
                obj.infoString = "Switch state EDFA";
            else
                obj.switchState = "unknown";
                obj.infoString = "Switch state unknown";
            end
        end
    end
end