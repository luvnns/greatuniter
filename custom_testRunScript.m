
%FPGA = mainApp.FPGA;
%result = test(FPGA)
% addStrOutput(mainApp.mainWindow,' хаю хай ');
% enableWarningLaser(mainApp.mainWindow);
% for i = 1:5
% refreshProgress(mainApp.mainWindow,i/5*100);
% pause(1)
% end
% disableWarningLaser(mainApp.mainWindow);
% setLabelsAxes(mainApp.mainWindow,'hello','eto xLabel','eto yLabel');
lastReadWaveform = '';            
tableWaveform = readmatrix(lastReadWaveform);
forSearch = tableWaveform(:,1);
searchArray = find(isnan(forSearch));
row = searchArray(end) + 1; %первая строка графика
tableWaveform = tableWaveform(row:end,:);
figureWaveform = tableWaveform;
x = figureWaveform(:,1);
y = figureWaveform(:,2);

title(axes,'Spectrum (log)');
xlabel(axes,'Wavelength, nm');
ylabel(axes,'Power, dBm');
plot(axes,x,y);