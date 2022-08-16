function funcAttenVolt = convertMatrixToFunc(matrix)

[Attenuation_dB, Voltage_V] = prepareCurveData(matrix(:,1), matrix(:,2));
[funcAttenVolt, gof] = fit(Attenuation_dB, Voltage_V, 'linearinterp', 'Normalize', 'on' );
end