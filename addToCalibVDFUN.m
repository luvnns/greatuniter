function coeff = addToCalibVDFUN(folder,mode,tableVD,lossdB,k_mkWadc,VD_ADC)
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

% figure;

% plot(x_mW,y_calib);
% hold on;
% plot(x_mW,y_idel);% идеал
% xlabel('Power, mW');
% ylabel('ADC');
% legend('real (measure)','ideal (calc)');
% title('Compare real and ideal')
% grid on

% %
% y_dBm = -40:0.1:20;
% y_mW = 10.^(y_dBm./10);
% x_calib = y_mW/powerMeasureVSPadcCalc.p1;
% x_idel = y_mW/coeffVDideal;
% y_calib_dBm = 10*log10(y_calib*coeffVDideal);
% y_idel_dBm = 10*log10(y_idel*coeffVDideal);
% y_dB = y_calib_dBm - y_idel_dBm;
% 
% %
% figure;
% y_dBm = -40:0.1:20;
% y_mW = 10.^(y_dBm./10);
% x_calib = y_mW/powerMeasureVSPadcMeasure.p1;
% x_idel = y_mW/coeffVDideal;
% x_calib_dBm = 10*log10(x_calib*coeffVDideal);
% x_idel_dBm = 10*log10(x_idel*coeffVDideal);
% x_dB = x_calib_dBm - x_idel_dBm;
% plot(y_dBm,x_dB);
% xlabel('Power, dBm');
% ylabel('PadcCalc - PadcMeasure, dB');
% title([VD_ADC_forPlot ' - Calibration test'])
% grid on

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

% figure;
% x_mW = 0:0.001:5;
% y_measure = x_mW*coeffVDreal;
% y_calc = x_mW*coeffVDideal;
% plot(x_mW,y_measure);
% hold on;
% plot(x_mW,y_calc);
% xlabel('Power, mW');
% ylabel('ADC');
% legend('real (measure)','ideal (calc)');
% title('Compare real and ideal')
% grid on

% 
% figure;
% x_mW = 0:0.001:5;
% x_dBm = 10*log10(x_mW);
% y_measure_dBm = 10*log10(y_measure);
% y_calc_dBm =  10*log10(y_calc);
% y_dB = y_measure_dBm - y_calc_dBm;
% plot(x_dBm,y_dB);
% xlabel('Power, dBm');
% ylabel('PadcCalc - PadcMeasure, dB');
% grid on
name = ['calib_' VD_ADC];
filename = [folder createFilename(name,time) '.mat'];
save(filename);
end