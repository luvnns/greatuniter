clc
clear

BAUDRATE = 57600;
SerialportDropDown = 'COM5';

virtualObject = serialport(SerialportDropDown,BAUDRATE);

request = "switch=line1";
writeline(virtualObject,request);
response = readline(virtualObject);
disp(response)

delete(virtualObject);