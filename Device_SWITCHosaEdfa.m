classdef Device_SWITCHosaEdfa
    properties (Constant)
        baudRate = 57600
        requestSwitchStateCommand = "data?;"
        requestSwitchOSACommand = "003;1;"
        requestSwitchEDFACommand = "003;0;"
        responseSwitchOSA = convertCharsToStrings(['1;1' char(13)])
        responseSwitchEDFA = convertCharsToStrings(['0;0' char(13)])
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
        function obj = Device_SWITCHosaEdfa(app)
            obj.serialPort = app.SerialportDropDown.Value;
            obj.virtualObject = serialport(obj.serialPort,obj.baudRate);
            obj = requestSwitchState(obj);
        end
        function obj = requestSwitchState(obj)
            requestCommand = obj.requestSwitchStateCommand;
            writeline(obj.virtualObject,requestCommand);
            obj = readSwitchState(obj);
        end
        function obj = switchSignalTo(obj,OSAorEDFAstring)
            if OSAorEDFAstring == "OSA"
                requestCommand = obj.requestSwitchOSACommand;
            elseif OSAorEDFAstring == "EDFA"
                requestCommand = obj.requestSwitchEDFACommand;
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
    methods (Access = private)
        function obj = readSwitchState(obj)
            %pause(0.5)
            obj.lastResponse = readline(obj.virtualObject);
            if obj.lastResponse == obj.responseSwitchOSA
                obj.switchState = "OSA";
                obj.infoString = "Switch state OSA";
            elseif obj.lastResponse == obj.responseSwitchEDFA
                obj.switchState = "EDFA";
                obj.infoString = "Switch state EDFA";
            else
                obj.switchState = "unknown";
                obj.infoString = "Switch state unknown";
            end
        end
    end
end