function deco_readms()

y = fuf ('C:\Deco\deco_demo_data\LC-MS\E-Coli\decoresults',1,'detail');
n = size(y);
fid = fopen('C:\Deco\lcms\E-coli.txt', 'w+');

for i=2:3:n-1,
    fname = char(y(i));
    ms = load(fname, '-mat');
    c = size(ms.s1);
    for j=1:c
        [v, idx] = max(ms.s1(j,:));
        dstr = [fname, '= ', int2str(idx+99)];
        display(dstr);
        fprintf(fid, '%s\n', dstr);
    end
    fprintf(fid, '\n');
end
fclose(fid)
end


