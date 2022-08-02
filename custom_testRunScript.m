
% clearAxes(mainApp.mainWindow);
setLabelsAxes(mainApp.mainWindow,'Spectrum (log)','Wavelength, nm','Power, dBm');

% plotWaveform(OSAyokogawa,mainApp.mainWindow);
% holdAxes(mainApp.mainWindow, 'on');

[x, y] = prepareForPlotDataFromOSA('tests\referenceTrace_waveform_20220802T172541.csv');
plotAxes(mainApp.mainWindow, x, y);
setLimsAxes(mainApp.mainWindow,[-inf inf],[-80 inf]);
%holdAxes(mainApp.mainWindow, 'off');
%setLegend(mainApp.mainWindow,{'Reference','Waveform'});