%% Initial parameters
sampleTablePath = 'C:\greatuniter_test2807\tables\testEDFA_ALL_LDD.xlsx';
userText = 'second_script_test';
referenceTrace = 'A';
waveformTrace = 'B';
rowNumberToWriteStart = 4;
rowNumberToWriteStop = 7;
rowNumberToReadStart = 13;
rowNumberToReadStop = 27;

%% Copy windows from the Great Uniter
OPMrubin_Power_input = mainApp.struct_OPMrubin.Power_input;
OSAyokogawa = mainApp.OSAyokogawa;
FPGA = mainApp.FPGA;
ATTENniMyDaq = mainApp.ATTENniMyDaq;
SWITCHosaEdfa = mainApp.SWITCHosaEdfa;
%% Get table from file
sampleTable = readtable(sampleTablePath);%'ReadRowNames',false,'ReadVariableNames',true

%% Cycle for table rows with showing in process(?)
tablePath = [OSAyokogawa.folder,filesep,userText,createFilename(now,'result_'),'.xlsx'];
ATTENniMyDaq = setAttenuation(ATTENniMyDaq,0);
FPGA = writeData(FPGA, FPGA.FLASH_MEM, 'MODE', '0');
FPGA = writeData(FPGA, FPGA.FLASH_MEM, 'LDD_EN', 'f');
varNames = sampleTable.Properties.VariableNames;
height_sampleTable = height(sampleTable);
statusTable = StatusTable(sampleTable);
for rowNumber = 1:height_sampleTable
    SWITCHosaEdfa = switchSignalTo(SWITCHosaEdfa,'OSA');
    powerTh = sampleTable{rowNumber,'InputPowerThDBm'};
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
    pause(sampleTable{rowNumber,'PauseAfterAttenuationS'});
    writeWaveform(OSAyokogawa,referenceTrace);
    pause(5);
    SWITCHosaEdfa = switchSignalTo(SWITCHosaEdfa,'EDFA');
    for j = rowNumberToWriteStart:rowNumberToWriteStop
        name = varNames{j};
        data = string(sampleTable{rowNumber,name});
        FPGA = writeData(FPGA, FPGA.FLASH_MEM, name, data);
    end

    pause(sampleTable{rowNumber,'PauseAfterSetOutputPowerS'})
    writeWaveform(OSAyokogawa,waveformTrace);
    OSAyokogawa = readWaveform(OSAyokogawa,waveformTrace);
    saveWaveform(OSAyokogawa,userText);
    sampleTable{rowNumber,'OutputPowerRealDBmOSA'} = readPower(OSAyokogawa,waveformTrace);
    OSAyokogawa = readAnalysisEDFANF(OSAyokogawa,waveformTrace);
    saveAnalysisEDFANF(OSAyokogawa,userText);
    edfa_nf_table = OSAyokogawa.lastReadAnalysisEDFANF;
    sampleTable{rowNumber,'MaxNF'} = max(edfa_nf_table{:,'nf'});
    sampleTable{rowNumber,'MeanGAIN'} = mean(edfa_nf_table{:,'gain'});
    sampleTable{rowNumber,'DeltaGAIN'} = max(edfa_nf_table{:,'gain'})-min(edfa_nf_table{:,'gain'});
    for z = rowNumberToReadStart:rowNumberToReadStop
        name = varNames{z};
        FPGA = readData(FPGA, FPGA.FLASH_MEM, name);
        sampleTable{rowNumber,name} = str2double(FPGA.lastRead);
    end
    
    writetable(sampleTable,tablePath);
    if ~isvalidFigure(statusTable)
        statusTable = StatusTable(sampleTable);
    else
        statusTable = refreshTable(statusTable,sampleTable);
    end
    clc
    %disp(sampleTable)
    fprintf('%0.0f %%\n', rowNumber/height_sampleTable*100)
end
FPGA = writeData(FPGA, FPGA.FLASH_MEM, 'LDD_EN', '0');
disp('finished')