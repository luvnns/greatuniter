t = readmatrix('EDFA_4\B04_total.xlsx');
Pinput = t(:,3);
Poutput = t(:,8);
maxNF = t(:,9);

plot3(Pinput,Poutput,maxNF);