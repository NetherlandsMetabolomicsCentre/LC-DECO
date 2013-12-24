function smax = deco_maximumscanlcms()

global project MVERSION SVERSION;

dir = project.sdir;
lcmsfiles = project.files;
maxscan = project.maxscan;
snr = [];

if MVERSION<=SVERSION,
numfiles = size(lcmsfiles, 2);
else
numfiles = size(lcmsfiles, 1);
end 

for i = 1:numfiles

    if MVERSION<=SVERSION, % check for matlab version
        cfilename = char(lcmsfiles(i));
        cdf_file = [dir cfilename];
        snr = [snr, cdf_extract_d(cdf_file,'scan_number')];
    else
       cfilename = lcmsfiles(i,1:end);
        cdf_file = [dir cfilename];
        data = cdfbwcompat(cdf_file);
        snr = [snr, data.snr];
    end
end

smax = min(snr);

end