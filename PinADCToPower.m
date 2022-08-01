function power = PinADCToPower(ADC,units)
% units = 'dBm', 'mW'
k_mkWadc = 0.00024;
lossdB = 19.26;

power = ADC * k_mkWadc/1000*10^(lossdB/10);

if isequal(units,'dBm')
power = 10*log10(power);
end
end