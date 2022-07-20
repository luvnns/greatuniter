%% Initial parameters
sampleTablePath = 'E:\greatuniter\tables\testEDFA_ALL_LDD.xlsx';
userText = 'first_script_test';
referenceTrace = 'A';
waveformTrace = 'B';
rowNumberToWriteStart = 5;
rowNumberToWriteStop = 8;
rowNumberToReadStart = 14;
rowNumberToReadStop = 28;

%% Copy windows from the Great Uniter
load('TheGreatUniterMemory.mat','mainApp');
assignin("base","mainApp",mainApp);

struct_OPMrubin = mainApp.struct_OPMrubin; %%%%%%%%%
OPMrubin_Power_input = struct_OPMrubin.Power_input;
disp(struct_OPMrubin)%%%%%%%%%
disp(struct_OPMrubin.Power_input)%%%%%%%%%
OSAyokogawa = mainApp.OSAyokogawa;
FPGA = mainApp.FPGA;
ATTENniMyDaq = mainApp.ATTENniMyDaq;
SWITCHosaEdfa = mainApp.SWITCHosaEdfa;

%% Get table from file
sampleTable = readtable(sampleTablePath);%'ReadRowNames',false,'ReadVariableNames',true

%% Cycle for table rows with showing in process(?)
tablePath = [OSAyokogawa.folder,filesep,userText,createFilename(now,'result_'),'.xlsx'];

varNames = app.sampleTable.Properties.VariableNames;
for rowNumber = 1:height(sampleTable)
    SWITCHosaEdfa = switchSignalTo(SWITCHosaEdfa,"OSA");
    powerTh = sampleTable{rowNumber,'InputPowerThDBm'};
    counter = 0;
    counterStop = 4;
    OPMrubin_Power_input = requestPower(OPMrubin_Power_input);
    powerReal = OPMrubin_Power_input.powerdBm(end);
    difference = powerTh - powerReal;
    while counter ~= counterStop && abs(difference) > 0.1
        attenuation = ATTENniMyDaq.lastAttenuation + difference;
        ATTENniMyDaq = setAttenuation(ATTENniMyDaq,attenuation);
        counter = counter + 1;
        OPMrubin_Power_input = requestPower(OPMrubin_Power_input);
        powerReal = OPMrubin_Power_input.powerdBm(end);
        difference = powerTh - powerReal;
    end
    sampleTable{rowNumber,'AttenuationForInputPowerDBm'} = ATTENniMyDaq.lastAttenuation;
    sampleTable{rowNumber,'InputPowerRealDBm'} = powerReal;
    pause(sampleTable{rowNumber,'PauseAfterAttenuationS'});
    writeWaveform(OSAyokogawa,referenceTrace);
    SWITCHosaEdfa = switchSignalTo(SWITCHosaEdfa,"EDFA");
    for j = rowNumberToWriteStart:rowNumberToWriteStop
        name = varNames{j};
        data = str(sampleTable{rowNumber,FPGAname});
        FPGA = writeData(FPGA, FPGA.FLASH_MEM, name, data);
    end
    FPGA = writeData(FPGA, FPGA.FLASH_MEM, 'MODE', '0');
    FPGA = writeData(FPGA, FPGA.FLASH_MEM, 'LDD_EN', 'f');
    pause(sampleTable{rowNumber,'PauseAfterSetOutputPowerS'})
    writeWaveform(OSAyokogawa,waveformTrace);
    OSAyokogawa = readWaveform(OSAyokogawa,waveformTrace);
    saveWaveform(OSAyokogawa,userText);
    sampleTable{rowNumber,'OutputPowerRealDBmOSA'} = readPower(OSAyokogawa,waveformTrace);
    OSAyokogawa = readAnalysisEDFANF(OSAyokogawa,waveformTrace);
    saveAnalysisEDFANF(OSAyokogawa,userText);
    disp(OSAyokogawa.lastReadAnalysisEDFANF)%%%%%%
    edfa_nf_table = OSAyokogawa.lastReadAnalysisEDFANF;
    sampleTable{rowNumber,'MaxNF'} = max(edfa_nf_table{:,'nf'});
    sampleTable{rowNumber,'MeanGAIN'} = mean(edfa_nf_table{:,'gain'});
    sampleTable{rowNumber,'DeltaGAIN'} = max(edfa_nf_table{:,'gain'})-min(edfa_nf_table{:,'gain'});
    for j = rowNumberToReadStart:rowNumberToReadStop
        name = varNames{j};
        FPGA = readData(FPGA, FPGA.FLASH_MEM, name);
        sampleTable{rowNumber,FPGAname} = double(FPGA.lastRead);
    end
    FPGA = writeData(FPGA, FPGA.FLASH_MEM, 'LDD_EN', '0');
    writetable(sampleTable,tablePath);
end