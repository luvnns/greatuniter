classdef SwitchOsaEdfa
    properties (Constant)
        switchStateRequest = "data?;"
        switch3on = "003;1;"
        switch3off = "003;0;"
        baudRate = 57600
    end
    properties
        comPort
        virtualObject
        switchState
    end
    methods
        function obj = SwitchOsaEdfa(app)
            obj.comPort = app.COMportsEditField.Value;
            obj.virtualObject = serialport(obj.comPort,obj.baudRate);
        end
        function obj = switchSignalOSA(obj)
            requestCommand = obj.switch3on;
            %disp(requestCommand)%%%
            writeline(obj.virtualObject,requestCommand);
            obj = readSwitchState(obj);
            if ~isequal(obj.switchState,"OSA")
                %error('switch is not working')
            end
        end
        function obj = switchSignalEDFA(obj)
            requestCommand = obj.switch3off;
            %disp(requestCommand)%%%
            writeline(obj.virtualObject,requestCommand);
            obj = readSwitchState(obj);
            if ~isequal(obj.switchState,"EDFA")
                %error('switch is not working')
            end
        end
        function obj = requestSwitchState(obj)
            requestCommand = obj.switchStateRequest;
            %disp(requestCommand)%%%
            writeline(obj.virtualObject,requestCommand);
            obj = readSwitchState(obj);
        end
        function obj = readSwitchState(obj)
            pause(0.5)
            response = readline(obj.virtualObject);
            %disp(response)%%%
            switchOSA = convertCharsToStrings(['1;1' char(13)]);
            switchEDFA = convertCharsToStrings(['0;0' char(13)]);
            if isequal(response,switchOSA)
                obj.switchState = "OSA";
            elseif isequal(response,switchEDFA)
                obj.switchState = "EDFA";
            end
            %disp(obj.switchState);%%%
        end
        function obj = sendCommand(obj,requestCommand)
            writeline(obj.virtualObject,requestCommand);
            obj.switchState = readline(obj.virtualObject);
        end
        function obj = deleteVirtualObject(obj)
            delete(obj.virtualObject);
        end
    end
end