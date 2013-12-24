function deco_lcmsinspectresults(block)

global project;
if project.extnipals,
    decoresults = project.deco_exnpls{block};
else
    decoresults = project.deco_mcr{block};
end
xtic = decoresults.xtic;
c = decoresults.c;
s = decoresults.s;
m = decoresults.msvx;
BEGIN = decoresults.begin;
END = decoresults.begin + decoresults.step*project.nfiles + project.nfiles-1;

figure;
plot(BEGIN:END,xtic);
axis tight;
if project.extnipals,
    title('TIC, Ext.NIPALS');
else
    title('TIC, MCR-ALS');
end


figure;
plot(BEGIN:END,c);
axis tight;
if project.extnipals,
    title('Concentration, Ext.NIPALS');
else
    title('Concentration, MCR-ALS');
end


[a, b] = size(s);

if a == 1
    ps = 1;
elseif a < 5
    ps = 2;
elseif a < 10
    ps = 3;
elseif a >= 10
    ps = 4;
end

figure;
for i=1:a,
    [v, vid] = sort(s(i,:), 'descend');
    hs = subplot(ps,ps,i);
    bar(hs, m,s(i,:));
    if project.extnipals,
        title(['Mass spectra -', int2str(i), ' Ext. NIPALS']);
    else
        title(['Mass spectra -', int2str(i), ' MCR-ALS']);
    end
end

end