function power = PoutADCToPower(ADC,units)
% units = 'dBm', 'mW'
k_mkWadc = 0.00457;
lossdB = 17.66;

power = ADC * k_mkWadc/1000*10^(lossdB/10);

if isequal(units,'dBm')
power = 10*log10(power);
end
end