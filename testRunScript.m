
FPGA = mainApp.FPGA;
result = test(FPGA)

sampleTablePath = 'C:\greatuniter_test2807\tables\testEDFA_ALL_LDD.xlsx';
testTable = readtable(sampleTablePath);
% fig = uifigure('Name','Status table');
% fig.Position = [20,150,1000,800];
% uit = uitable(fig,'Data',testTable);
% uit.Units = 'normalized';
% uit.Position = [0.01, 0.01, 0.99, 0.99];
% uit.BackgroundColor(2,:) = [0.96,0.96,1];
% uit.FontSize = 16;
% uit.ColumnWidth = 'fit';
statusTable = StatusTable(testTable);
for i = 1:15
    testTable{i,'InputPowerThDBm'} = 666;
    if ~isvalidFigure(statusTable)
        statusTable = StatusTable(testTable);
    else
        statusTable = refreshTable(statusTable,testTable);
    end
    pause(5)
    clc
    fprintf('%0.0f %%\n', i/50*100)
end