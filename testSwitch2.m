BAUDRATE = 57600;
SerialportDropDown = 'COM5';

virtualObject = serialport(SerialportDropDown,BAUDRATE);

obj = Device_SWITCHosaEdfaTwoLines(appStruct);

obj = requestSwitchState(obj);
disp(obj.switchState);
%%
OSAorEDFAstring = "OSA";%, "EDFAFirstLine" or "EDFASecondLine"
obj = switchSignalTo(obj,OSAorEDFAstring);
disp(obj.switchState)
%obj = sendCommand(obj,requestCommand);

%%
obj = deleteVirtualObject(obj);