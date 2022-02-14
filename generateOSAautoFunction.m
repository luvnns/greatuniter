%%
clc
clear

periodSec = 1;
timeSec = 60;
tableName = 'OSAautoFunction.xlsx';
%okruglenie proishodit v bol'shuyu storonu

%%
numRows = ceil(timeSec/periodSec);
initTable = readtable(tableName,...
    "ReadRowNames",false,...
    "ReadVariableNames",true);
varNames = initTable.Properties.VariableNames;
numVars = width(initTable);
x = zeros(numRows, numVars);
x(:,1) = periodSec;
newTable = array2table(x,'VariableNames',varNames);
writetable(newTable,tableName,'WriteVariableNames',true);
