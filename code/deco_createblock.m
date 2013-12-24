function [xblock, msv, rtx] = deco_createblock(datamatname, BEGIN, STEP, block_mass_model_chk, block_mass_error_thd)

global project MVERSION SVERSION;
NOISE_THRESHOLD = project.noisethresh;

if MVERSION<=SVERSION,
    nd = size(datamatname, 2);
else
    nd = size(datamatname, 1);
end

MASS_MODEL = block_mass_model_chk;
ERROR_THD = block_mass_error_thd;

msix = [];
msvax = [];
rtx = [];

for i=1:nd
    if MVERSION<=SVERSION,
        matname = strcat(substr(char(datamatname(i)), 0, -4),'_bcor.mat');
    else
        matname = [datamatname(i,1:end-4),'_bcor.mat'];
    end
    load(char(matname), '-mat');
    data = msi(:, BEGIN:BEGIN+STEP);
    if (MASS_MODEL)
        [data, msv, msva, er2] = deco_modelmass(data, msv, msva, ERROR_THD);
        BLOCK_BEGIN = BEGIN;
        save(matname, 'er2', 'BLOCK_BEGIN', '-mat', '-append'); % Warning..!! This is a temporary field, and is defined for 'mass model error display functionality' and is defined for a block that is currently processed, and will be overwritten.
    end
    
    [data, msva] = deco_blockselectmasses(data', msva, NOISE_THRESHOLD);
%     data = sgolayfilt(data, 3, 21);
    data = data';
    
    msix = [msix; single(data)];
    msvax = [msvax; single([msva, ones(size(msva,1),1)*i])];
%     rtd = rt(BEGIN:BEGIN+STEP);
    rtx = [rtx; single(rt(BEGIN:BEGIN+STEP))];
end

[xblock, msv] = deco_lcmsbinmultipledata(msix, msvax, nd);

end