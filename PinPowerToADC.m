function ADC = PinPowerToADC(power,units)
% units = 'dBm', 'mW'
k_mkWadc = 0.00024;
lossdB = 19.26;

if isequal(units,'dBm')
power = 10^(power/10);
end

ADC = power * 1000/(k_mkWadc*10^(lossdB/10));
end