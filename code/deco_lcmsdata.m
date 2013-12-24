function [data, msv] = deco_lcmsdata(data1, data2, data3)

data = [];

load(data1, '-mat');
msi1 = msi;

load(data2, '-mat');
msi2 = msi;

load(data3, '-mat');
msi3 = msi;

data = [msi1, msi2, msi3];
msv = msva;


end