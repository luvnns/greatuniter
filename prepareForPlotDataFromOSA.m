function [x, y] = prepareForPlotDataFromOSA(filenameCsv)
tableWaveform = readmatrix(filenameCsv);
forSearch = tableWaveform(:,1);
searchArray = find(isnan(forSearch));
row = searchArray(end) + 1; %первая строка графика
tableWaveform = tableWaveform(row:end,:);
figureWaveform = tableWaveform;
x = figureWaveform(:,1);
y = figureWaveform(:,2);
end