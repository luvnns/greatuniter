function w = dbm2w(dbm,metricPrefix)
% metricPrefix may be
% 'n' = nano = 10^-9
% 'u' = micro = 10^-6
% 'm' = milli = 10^-3
% ' ' = one = 1
realW = (10.^(dbm/10))*1000;


metricArray = {' ', 'm', 'u', 'n'};
ind = find(strcmp(metricArray, metricPrefix)==1);
multiple = 10^(-3*(ind-1));
realW = w * multiple;
dbm = 10 * log10(realW * 1000);

end