%% Initial parameters
tablePath = 'E:\greatuniter\tables\testEDFA_ALL_LDD.xlsx';

%% Copy windows from the Great Uniter
load('TheGreatUniterMemory.mat','mainApp');
assignin("base","mainApp",mainApp);

struct_OPMrubin = mainApp.struct_OPMrubin; %%%%%%%%%
OSAyokogawa = mainApp.OSAyokogawa;
FPGA = mainApp.FPGA;
ATTENniMyDaq = mainApp.ATTENniMyDaq;
SWITCHosaEdfa = mainApp.SWITCHosaEdfa;

%% Get table from file
sampleTable = readtable(tablePath);%'ReadRowNames',false,'ReadVariableNames',true

%% Cycle for table rows with showing in process(?) *append
for rowNumber = 1:height(sampleTable)
    sampleTable{rowNumber,'InputPowerThDBm'}




end