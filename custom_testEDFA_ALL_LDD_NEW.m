%% Initial parameters
sampleTablePath = 'C:\greatuniter_test2807\tables\testEDFA_ALL_LDD.xlsx';
userText = 'test';
referenceTrace = 'A';
waveformTrace = 'B';
varNumberToWriteStart = 4;
varNumberToWriteStop = 7;
varNumberToReadStart = 13;
varNumberToReadStop = 27;

%% Copy windows from the Great Uniter
OPMrubin_Power_input = mainApp.struct_OPMrubin.Power_input;
OSAyokogawa = mainApp.OSAyokogawa;
FPGA = mainApp.FPGA;
ATTENniMyDaq = mainApp.ATTENniMyDaq;
SWITCHosaEdfa = mainApp.SWITCHosaEdfa;
%% Get table from file
sampleTable = readtable(sampleTablePath);

%% Cycle for table rows with showing in process
refreshProgress(mainApp.mainWindow,0);
tablePath = [OSAyokogawa.folder,filesep,userText,createFilename(now,'result_'),'.xlsx'];
addStrOutput(mainApp.mainWindow,[ ...
    'There was created table: ', ...
    tablePath, ...
    ]);
addStrOutput(mainApp.mainWindow,'');
addStrOutput(mainApp.mainWindow,'DO NOT OPEN TABLE UNTIL FINISHED');
addStrOutput(mainApp.mainWindow,'Use opened figure instead');
addStrOutput(mainApp.mainWindow,'');
ATTENniMyDaq = setAttenuation(ATTENniMyDaq,0);
FPGA = writeData(FPGA, FPGA.FLASH_MEM, 'MODE', '0');
addStrOutput(mainApp.mainWindow,'Write to FPGA MODE = 0');
enableWarningLaser(mainApp.mainWindow);
FPGA = writeData(FPGA, FPGA.FLASH_MEM, 'LDD_EN', 'f');
addStrOutput(mainApp.mainWindow,'Write to FPGA LDD_EN = F');
varNames = sampleTable.Properties.VariableNames;
height_sampleTable = height(sampleTable);
statusTable = StatusTable(sampleTable);
for rowNumber = 1:height_sampleTable
    SWITCHosaEdfa = switchSignalTo(SWITCHosaEdfa,'OSA');
    addStrOutput(mainApp.mainWindow,SWITCHosaEdfa.infoString);
    powerTh = sampleTable{rowNumber,'InputPowerThDBm'};
    addStrOutput(mainApp.mainWindow,'Calibrate attenuation...');
    counter = 0;
    counterStop = 6;
    OPMrubin_Power_input = requestPower(OPMrubin_Power_input);
    powerReal = OPMrubin_Power_input.powerdBm(end);
    difference = powerReal - powerTh;
    while counter ~= counterStop && abs(difference) > 0.1
        attenuation = difference + ATTENniMyDaq.lastAttenuation;
        ATTENniMyDaq = setAttenuation(ATTENniMyDaq,attenuation);
        counter = counter + 1;
        OPMrubin_Power_input = requestPower(OPMrubin_Power_input);
        powerReal = OPMrubin_Power_input.powerdBm(end);
        difference = powerReal - powerTh;
    end
    sampleTable{rowNumber,'InputPowerRealDBm'} = powerReal;
    addStrOutput(mainApp.mainWindow,['Attenuation is ', num2str(attenuation)]);
    pauseAfterAttenuation = sampleTable{rowNumber,'PauseAfterAttenuationS'};
    addStrOutput(mainApp.mainWindow,['Pause for ',num2str(pauseAfterAttenuation),' s']);
    pause(pauseAfterAttenuation);
    addStrOutput(mainApp.mainWindow,['Write reference trace ',referenceTrace]);
    writeWaveform(OSAyokogawa,referenceTrace);
    readWaveform(OSAyokogawa,referenceTrace);
    OSAyokogawa = saveWaveform(OSAyokogawa,referenceTrace);
    clearAxes(mainApp.mainWindow);
    setLabelsAxes(mainApp.mainWindow,'Spectrum (log)','Wavelength, nm','Power, dBm');
    plotWaveform(OSAyokogawa,mainApp.mainWindow);
    holdAxes(mainApp.mainWindow, 'on');
    SWITCHosaEdfa = switchSignalTo(SWITCHosaEdfa,'EDFA');
    addStrOutput(mainApp.mainWindow,SWITCHosaEdfa.infoString);
    for j = varNumberToWriteStart:varNumberToWriteStop
        name = varNames{j};
        data = string(sampleTable{rowNumber,name});
        FPGA = writeData(FPGA, FPGA.FLASH_MEM, name, data);
        addStrOutput(mainApp.mainWindow,['Write to FPGA ',name,' = ',data]);
    end
    pauseAfterSetOutputPower = sampleTable{rowNumber,'PauseAfterSetOutputPowerS'};
    addStrOutput(mainApp.mainWindow,['Pause for ',num2str(pauseAfterSetOutputPower),' s']);
    pause(pauseAfterSetOutputPower)
    addStrOutput(mainApp.mainWindow,['Write waveform trace ',waveformTrace]);
    writeWaveform(OSAyokogawa,waveformTrace);
    addStrOutput(mainApp.mainWindow,['Read waveform trace ',waveformTrace]);
    OSAyokogawa = readWaveform(OSAyokogawa,waveformTrace);
    addStrOutput(mainApp.mainWindow,['Save waveform trace ',waveformTrace]);
    OSAyokogawa = saveWaveform(OSAyokogawa,userText);
    plotWaveform(OSAyokogawa,mainApp.mainWindow);
    holdAxes(mainApp.mainWindow, 'off');
    setLegend(mainApp.mainWindow,{'Reference','Waveform'});
    addStrOutput(mainApp.mainWindow,'Read waveform parameters');
    sampleTable{rowNumber,'OutputPowerRealDBmOSA'} = readPower(OSAyokogawa,waveformTrace);
    OSAyokogawa = readAnalysisEDFANF(OSAyokogawa,waveformTrace);
    saveAnalysisEDFANF(OSAyokogawa,userText);
    edfa_nf_table = OSAyokogawa.lastReadAnalysisEDFANF;
    sampleTable{rowNumber,'MaxNF'} = max(edfa_nf_table{:,'nf'});
    sampleTable{rowNumber,'MeanGAIN'} = mean(edfa_nf_table{:,'gain'});
    sampleTable{rowNumber,'DeltaGAIN'} = max(edfa_nf_table{:,'gain'})-min(edfa_nf_table{:,'gain'});
    addStrOutput(mainApp.mainWindow,'Read FPGA parameters');
    for z = varNumberToReadStart:varNumberToReadStop
        name = varNames{z};
        FPGA = readData(FPGA, FPGA.FLASH_MEM, name);
        sampleTable{rowNumber,name} = str2double(FPGA.lastRead);
    end
    addStrOutput(mainApp.mainWindow,'Update result table');
    writetable(sampleTable,tablePath);
    if ~isvalidFigure(statusTable)
        statusTable = StatusTable(sampleTable);
    else
        statusTable = refreshTable(statusTable,sampleTable);
    end
    progress = rowNumber / height_sampleTable * 100;
    refreshProgress(mainApp.mainWindow,progress);
end
FPGA = writeData(FPGA, FPGA.FLASH_MEM, 'LDD_EN', '0');
addStrOutput(mainApp.mainWindow,'Write to FPGA LDD_EN = 0');
disableWarningLaser(mainApp.mainWindow);
addStrOutput(mainApp.mainWindow,'Custom script finished');