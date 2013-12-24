function deco_lcmsscannumber2retentiontime()

global project;
lcmsfiles = project.files;

datamatname = strcat(substr(char(lcmsfiles(1)), 0, -4),'.mat');
lcmsdata1 = load(datamatname, '-mat');
msi1 = lcmsdata1.msi(:, 422:558);
msva = lcmsdata1.msva;
msvax = [msva, ones(size(msva,1),1)*1];

datamatname = strcat(substr(char(lcmsfiles(2)), 0, -4),'.mat');
lcmsdata2 = load(datamatname, '-mat');

msi2 = lcmsdata2.msi(:, 455:596);
msva = lcmsdata2.msva;
msvax = [msvax; [msva, ones(size(msva,1),1)*2]];

padnrs = size(msi2, 2) - size(msi1, 2);
padzeros = zeros(size(msi1, 1), padnrs);

msi1 = [msi1 padzeros];
data = [msi1; msi2];

[xblock, msv] = deco_lcmsbinmultipledata(data, msvax, 2);

[c, s] = deco_fixspectra(0, xblock, 3, 2);

end