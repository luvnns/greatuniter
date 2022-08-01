function coeff = addToCalibVDFUN(folder,mode,whatFig,tableVD,lossdB,k_mkWadc,VD_ADC)
% whatFig = 'get','test'
if isequal(mode,'in')
    Pnum = ['PIN' VD_ADC(end-1:end)];
    xLabel = 'P input (real OPM), mW';
    powerMeasure = tableVD{:,'InputPowerRealMW'};
    %x_mW = 0:0.001:5; 
    x_dBm = -40:0.1:5;
elseif isequal(mode,'out')
    Pnum = ['POUT' VD_ADC(end-1:end)];
    xLabel = 'P output (real OPM), mW';
    powerMeasure = tableVD{:,'OutputPowerRealMW'};
    %x_mW = 0:0.001:60;
    x_dBm = -30:0.1:18;
end

x_mW = 10.^(x_dBm./10);

VD_ADC_forPlot = replace(VD_ADC,'_',' ');
time = now;

yLabel = 'ADC (detect EDFA)';
PadcMeasure = tableVD{:,Pnum};

coeffVDideal = 1/(k_mkWadc/1000*10^(lossdB/10));
powerCalc = 1/coeffVDideal*PadcMeasure;
% disp('coeffVDideal');
% disp(coeffVDideal);

figure;
hold on;
% Построение графика - идеальные точки
plot(powerCalc,PadcMeasure,'b-');

%Построение графика P_FILT_CAL
plot(powerMeasure,PadcMeasure,'Marker','x','MarkerSize',10,'LineStyle','none','LineWidth',2);
powerMeasureVSPadcMeasure = createFit(powerMeasure,PadcMeasure);
plot(powerMeasureVSPadcMeasure);
% Вывод коэф. этой прямой
coeffVDreal = powerMeasureVSPadcMeasure.p1;
% disp('coeffVDreal');
% disp(coeffVDreal);

% Расчет итоговых точек, чтобы совпали с идеальными
PadcCalc = PadcMeasure * coeffVDideal/coeffVDreal;
% Построение точек прямой, на которую должны лечь точки P_FILT_CAL
plot(powerMeasure,PadcCalc,'Marker','x','MarkerSize',10,'LineStyle','none','LineWidth',2);
filename = [createFilename('calib',time) '.mat'];
save(filename);
powerMeasureVSPadcCalc = createFit(powerMeasure,PadcCalc);%%
plot(powerMeasureVSPadcCalc,'g');
disp('Значение для ЕЕПРОМ')
coeff = 65536*coeffVDideal/coeffVDreal;
disp(VD_ADC)
disp(coeff);

%Подписи на графике
coeffI = ['ideal (const), k = ' num2str(coeffVDideal)];
real = 'P FILT CAL (real measure)';
coeffR = ['P FILT CAL, k = ' num2str(coeffVDreal)];
calibId = ['ideal after calibration, k = ' num2str( 65536*coeffVDideal/coeffVDreal)];
legend({coeffI,real,coeffR,calibId,calibId});
grid on;
xlabel(xLabel);
ylabel(yLabel);
title(VD_ADC_forPlot);
filename = [folder createFilename(VD_ADC,time) '.fig'];
savefig(filename);

if isequal(whatFig,'get')
% для первого этапа (калибровка)
figure;
y_calib = x_mW*powerMeasureVSPadcCalc.p1;
y_idel = x_mW*coeffVDideal;
y_calib_dBm = 10*log10(y_calib/coeffVDideal);
y_idel_dBm = 10*log10(y_idel/coeffVDideal);
y_dB = y_calib_dBm - y_idel_dBm;
plot(x_dBm,y_dB);
xlabel('Power, dBm');
ylabel('PadcCalc - PadcMeasure, dB');
title([VD_ADC_forPlot ' - Calibration'])
grid on
filename = [folder createFilename([VD_ADC '_Calibration'],time) '.fig'];
savefig(filename);
elseif isequal(whatFig,'test')
% для второго этапа (проверка калибровки)
figure;
y_calib_real = x_mW*powerMeasureVSPadcMeasure.p1;
y_idel = x_mW*coeffVDideal;
y_calib_real_dBm = 10*log10(y_calib_real/coeffVDideal);
y_idel_dBm = 10*log10(y_idel/coeffVDideal);
y_dB = y_calib_real_dBm - y_idel_dBm;
plot(x_dBm,y_dB);
xlabel('Power, dBm');
ylabel('PadcCalc - PadcMeasure, dB');
title([VD_ADC_forPlot ' - Calibration test'])
grid on
filename = [folder createFilename([VD_ADC '_CalibrationTest'],time) '.fig'];
savefig(filename);
end

name = ['calib_' VD_ADC];
filename = [folder createFilename(name,time) '.mat'];
save(filename);
end