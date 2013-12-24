function deco_multiplefilebaselinecorrection()

global project MVERSION SVERSION;
lcmsfiles = project.files;
entthresh = project.entthresh*project.maxentrpy;

if MVERSION <=SVERSION
    numfiles = size(lcmsfiles, 2);
else
   numfiles = size(lcmsfiles,1); 
end

h = waitbar(0,'Baseline correction in progress, please wait...');

for i = 1:numfiles
    if MVERSION<=SVERSION,    
        datamatname = strcat(substr(char(lcmsfiles(i)), 0, -4),'.mat');
    else
        datamatname = [char(lcmsfiles(i,1:end-4)) '.mat'];
    end
    deco_lcmsbaselinecorrection(datamatname,entthresh);
    waitbar(i/numfiles);
end
close(h);
end

function deco_lcmsbaselinecorrection(data, CHROM_ENT_THRESHOLD)

load(data, '-mat');

msi = msi(msetr<=CHROM_ENT_THRESHOLD, :);
msva = msva(msetr<=CHROM_ENT_THRESHOLD);
msv = msv(msetr<=CHROM_ENT_THRESHOLD, :);

matname = substr(data, 0, -4);

save([matname, '_bcor.mat'],'msi', 'msv', 'msva', 'rt', '-mat');

end