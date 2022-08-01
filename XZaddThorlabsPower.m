operationWave = '947';
meanInt = '1';
loss = '0';
visaAddress = 'USB0::0x1313::0x80B0::P3000699::INSTR';
filter = '0'; % 0 on, 1 off
units = 'DBM'; % W or DBM

thor = ThorlabsPower(operationWave,meanInt,loss,visaAddress,filter,units);
thor = setParam(thor);
thor = readData(thor);
thor = deleteVirtualObject(thor);