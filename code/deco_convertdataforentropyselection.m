function deco_convertdataforentropyselection(datamatname)

% 1PL-TRS-QC-05.mat
% ev = 0.62637;
ev = 1.0;

load(char(datamatname), '-mat');
load('met5', '-mat');
load('lmet5', '-mat');

% msi1 = msi(msetr ./max(msetr) <= ev, :);
% msva = msva(msetr ./max(msetr)<= ev);
% msetr1 = msetr(msetr ./max(msetr) <= ev);

msi1 = msi;
msetr1 = msetr;

msi2 = abs(diff(msi1, 1, 2));
msetr2 = calculateentropy(msi2);

[a, b] = sort(msetr1);
% msetr1 = msetr1(b)./max(msetr1);
% msetr2 = msetr2(b)./max(msetr1);

msetr1 = msetr1(b);
msetr2 = msetr2(b);

msva = msva(b);
msi1 = msi1(b, :);

figure; hold on; axis tight; scatter (msetr1, msetr2, 'DisplayName', ' msetr2 vs msetr1', 'XDataSource', 'msetr1', 'YDataSource', 'msetr2'); figure(gcf);

mb = size(met5);
x = [];
y = [];
index = [];

for i = 1: mb
    scatter(msetr1(fix(msva)==fix(met5(i, 1))), msetr2(fix(msva)==fix(met5(i, 1))), '*', 'green');
    index = [index; find(fix(msva)==fix(met5(i, 1)))];
    x = [x; msetr1(fix(msva)==fix(met5(i, 1)))];
    y = [y; msetr2(fix(msva)==fix(met5(i, 1)))];
end

hold off;

figure; hold on; 
a1 = [0 1500]; b1 = [0.62637, 0.62637];
plot(a1, b1*max(msetr1));

a1 = [0 1500]; b1 = [0.3594, 0.3594];
plot(a1, b1*max(msetr1));

a1 = [0 1500]; b1 = [0.1939, 0.1939];
plot(a1, b1*max(msetr1));

plot (msetr1, 'DisplayName', 'msetr1', 'YDataSource', 'msetr1'); axis tight; figure(gcf);
scatter (index, x, 'DisplayName', ' x vs index', 'XDataSource', 'index', 'YDataSource', 'x'); axis tight; figure(gcf);
plot (msetr2, 'DisplayName', 'msetr2', 'YDataSource', 'msetr2'); axis tight; figure(gcf);
%scatter (index, y, 'DisplayName', ' y vs index', 'XDataSource', 'index', 'YDataSource', 'y', 'color', 'red'); figure(gcf);
scatter (index, y, 'red'); axis tight; figure(gcf);

hold off;

p = polyfit(x, y, 1);
f = polyval(p, 0:0.1:1); 
plot(0:0.1:1, f, 'r');

err = (polyval(p, msetr1) - msetr2);
[m, n] = sort(err);
merr = msva(n);

mb = size(lmet5);

for i = 1: mb
    scatter(msetr1(fix(msva)==fix(lmet5(i, 1))), msetr2(fix(msva)==fix(lmet5(i, 1))), '+', 'red');
end

hold off;

end

function e = calculateentropy(data)

[m, n] = size(data);
e = zeros(m, 1);
for i = 1: m
    e(i) = deco_entropy(data(i, :));
end

end

























% msi = msi(msetr ./max(msetr) <= ev, :);
% msv = msv(msetr ./max(msetr) <= ev, :);
% msva = msva(msetr ./max(msetr)<= ev);
% msetr = msetr(msetr ./max(msetr) <= ev);


% mb = size(met5);
% mcindex = [];
% for i = 1: mb
%     y = find(fix(msva)==fix(met5(i, 1)));
%     mcindex = [mcindex; y];
% end
% 
% msi(mcindex, :) = [];
% msv(mcindex, :) = [];
% msva(mcindex) = [];
% msetr(mcindex) = [];
% 
% % smatname = strcat(substr(char(datamatname), 0, -4),'.mat');
% save(datamatname, 'msi', 'msv', 'msva', 'msetr', 'rt');