function deco_plotlcmsresults(BEGIN,END,md)
if nargin<3, md = 1; end;

dirn = ['C:\Deco\deco_demo_data\LC-MS\Tomato\3 times same sample powder\TNO-DECO results\', int2str(BEGIN),'-',int2str(END)];

filename = [dirn, '\lcmsresult.mat'];
load(filename, '-mat');

[x1, x2] = size(x);
END = BEGIN + x1 -1;

figure;
plot(BEGIN:END,sum(x,2));
title('TIC');

figure;
plot(BEGIN:END,x);
title('Mass Chromatogram');

figure;
plot(BEGIN:END,c);
title('Concentration');

[a, b] = size(s);

for i=1:a,
    %[v, vid] = max(s(i,:));
    [v, vid] = sort(s(i,:), 'descend');
    display(m(vid(1:md)));
    figure;
    bar(m,s(i,:));
    title(['Mass spectra -', int2str(i)]);
end

pause;
close all;
clear all;

end