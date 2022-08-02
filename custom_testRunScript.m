
clearAxes(mainApp.mainWindow);
setLabelsAxes(mainApp.mainWindow,'Spectrum (log)','Wavelength, nm','Power, dBm');

plotWaveform(OSAyokogawa,mainApp.mainWindow);
holdAxes(mainApp.mainWindow, 'on');

[x, y] = prepareForPlotDataFromOSA('b_waveform_20220802T161345.csv');
plotAxes(mainApp.mainWindow, x, y);

holdAxes(mainApp.mainWindow, 'off');
setLegend(mainApp.mainWindow,{'Reference','Waveform'});