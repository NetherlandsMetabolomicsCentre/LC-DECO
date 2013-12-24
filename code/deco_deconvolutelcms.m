function deco_deconvolutelcms()

global project;
lcmsfiles = project.files;
LEVEL = project.noiselevel;     % noise level corrector in estimate peaks
NOISE_THRESHOLD = project.noisethresh;
BEGIN_CHROM = project.minscan;
STEP = project.blocksize;
END_CHROM = project.maxscan;
target = project.target;
ns = size(lcmsfiles,2); % number of sample files
%datamatname = strcat(substr(char(lcmsfiles), 0, -4),'_bcor.mat');
blocknum = 1;
lcmsdecobegin = 1;

if project.extnipals,
    project.deco_exnpls = cell(0,0); % the deco resuls in ext.nipals
else
    project.deco_mcr    = cell(0,0); % the deco resuls in mcr-als
end

if (target)
    deco_locatetargetmassinblocks();
end

BLOCK_REDO = 0;

for BEGIN = BEGIN_CHROM:STEP:END_CHROM,
    END = BEGIN + STEP;
    if (END > END_CHROM)
        END = END_CHROM;
        STEP = END - BEGIN;
        lcmsdecobegin = 0;
    end
    
    deco_deconvoluteblock(BLOCK_REDO, blocknum, BEGIN, STEP, 0, 0, 0.75, 0, 0.25);
    
%     [xblock, msvx, rtx] = deco_createblock(lcmsfiles, BEGIN, STEP);
%     xtic = sum(xblock, 2);
%     [xblock, msvx] = deco_blockselectmasses(xblock, msvx, NOISE_THRESHOLD);
%     np = deco_estimate_lcmsblock(xblock, LEVEL);
%     if project.extnipals,
%         [c, s] = deco_fixspectra(0, xblock, np, ns);
%     else
%         [c, s] = deco_process_block(0, xblock, np);
%     end
%     deco_estimatearealcms(blocknum, xtic, c, s, msvx, ns, np, BEGIN, 1, STEP, rtx);
    blocknum = blocknum + 1;
    if (~lcmsdecobegin) 
        return; 
    end
end

end