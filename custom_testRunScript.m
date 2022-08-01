
%FPGA = mainApp.FPGA;
%result = test(FPGA)
addStrOutput(mainApp.mainWindow,'hello');
enableWarningLaser(mainApp.mainWindow);
for i = 1:5
refreshProgress(mainApp.mainWindow,i/5*100);
pause(1)
end
disableWarningLaser(mainApp.mainWindow);