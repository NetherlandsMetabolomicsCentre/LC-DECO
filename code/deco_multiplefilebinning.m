function deco_multiplefilebinning()

global project MVERSION SVERSION;
dir = project.sdir;
lcmsfiles = project.files;
maxscan = project.maxscan;
minscan = project.minscan;

if MVERSION<=SVERSION,
    numfiles = size(lcmsfiles, 2);
else
    numfiles = size(lcmsfiles, 1);
end
h = waitbar(0,'Binning in progress, please wait...');

if MVERSION<=SVERSION,
    for i = 1:numfiles
        cfilename = char(lcmsfiles(i));
        cdf_file = [dir cfilename];
        matname = [substr(cfilename, 0, -4) '.mat'];
        
        
        [msv, msi, msva, msetr, rt] = deco_lcmsbindatablock(cdf_file, maxscan, minscan); %#ok<NASGU,ASGLU>
        save(matname,'msv', 'msi', 'msva', 'msetr', 'rt', '-mat');
        clear msv msi msva msetr rt;
        
        waitbar(i/numfiles);
    end
else
    for i = 1:numfiles
        cfilename = lcmsfiles(i,1:end);
        cdf_file = [dir cfilename];
        matname = [cfilename(1:end-4) '.mat'];
        
        [msv, msi, msva, msetr, rt] = deco_lcmsbindatablock(cdf_file, maxscan, minscan); %#ok<NASGU,ASGLU>
        
        save(matname,'msv', 'msi', 'msva', 'msetr', 'rt', '-mat');
        clear msv msi msva msetr rt;
        
        
        waitbar(i/numfiles);
    end
end
close(h);
end