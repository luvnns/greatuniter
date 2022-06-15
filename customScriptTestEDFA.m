load('TheGreatUniterMemory.mat','mainApp');
assignin("base","mainApp",mainApp);

struct_OPMrubin = mainApp.struct_OPMrubin; %%%%%%%%%
OSAyokogawa = mainApp.OSAyokogawa;
FPGA = mainApp.FPGA;
ATTENniMyDaq = mainApp.ATTENniMyDaq;
SWITCHosaEdfa = mainApp.SWITCHosaEdfa;



%result = test(FPGA)