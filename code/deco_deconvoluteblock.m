function deco_deconvoluteblock(BLOCK_REDO, blocknr, BEGIN_BLOCK, STEP, peaknrs, block_isodist_chk, block_isodist_value, block_mass_model_chk, block_mass_error_thd)

global project;
lcmsfiles = project.files;
LEVEL = project.noiselevel;     % noise level corrector in estimate peaks
NOISE_THRESHOLD = project.noisethresh;
ns = project.nfiles; % number of sample files
target = project.target;
minscan = project.minscan;
mcor = [];
BLOCK_ISO_DIST = block_isodist_chk;

[xblock, msvx, rtx] = deco_createblock(lcmsfiles, BEGIN_BLOCK-minscan+1, STEP, block_mass_model_chk, block_mass_error_thd);
xtic = sum(xblock, 2);

if(BLOCK_REDO)
    np = peaknrs;
else
    np = deco_estimate_lcmsblock(xblock, LEVEL);
end

if (BLOCK_ISO_DIST && BLOCK_REDO)
    [xblock, msvx, np, s, c, mcor] = deco_blockselectmasseswithisotopicdistributions(xblock', msvx, peaknrs, block_isodist_value);
else
    [xblock, msvx] = deco_blockselectmasses(xblock, msvx, NOISE_THRESHOLD);
 
    if project.extnipals,
        display('Deconvolution method: Ext. NIPALS');
        [c, s] = deco_fixspectra(0, xblock, np, ns);
    else
        display('Deconvolution method: MCR-ALS');
        [c, s] = deco_process_block(0, xblock, np);
    end
    
end

if (target && BLOCK_REDO)
    xblockt = xblock - c*s;
    [ct, st] = deco_deconvolutewithmassknowledge(xblockt, msvx, BEGIN_BLOCK, s);
    c = [c ct];
    s = [s; st];
    np = size(c, 2);
end

deco_estimatearealcms(blocknr, xtic, c, s, msvx, ns, np, BEGIN_BLOCK, 1, STEP, rtx, mcor, block_isodist_chk, block_isodist_value, block_mass_model_chk, block_mass_error_thd);

display(['Completed deconvolution for block: ', num2str(blocknr)]);

end

% function [xblock, m] = deco_blockselectmasses(xblock, m, NOISE_THRESHOLD)
% 
% tic = sum(xblock, 1);
% mx = max(tic);
% tic = tic / mx;
% xblock = xblock(:,tic>=NOISE_THRESHOLD);
% m = m(tic>=NOISE_THRESHOLD);
% 
% end

function deco_estimatearealcms(blocknum, xtic, c, s, msvx, ns, np, BEGIN_BLOCK, BEGIN, STEP, rtx, mcor, block_isodist_chk, block_isodist_value, block_mass_model_chk, block_mass_error_thd)

global project;

pa = zeros(ns, np);
pmax = zeros(ns, np);
pmaxindex = zeros(ns, np);
rtopt = zeros(ns, STEP+1);
for i = 1:ns
    START = (i-1)*STEP + BEGIN + (i-1);
    END = START + STEP;
    rtopt(i, :) = rtx(START:END);
    for j = 1:np
        copt = c(START:END, j);
        sopt = s(j, :);
        pa(i, j) = sum(sum(copt*sopt));
        [pmax(i, j), pmaxindex(i, j)] = max(copt);
    end
end

decoresults = struct('xtic', xtic, 'c', c, 's', s, 'peaknrs', np, 'msvx', msvx, 'rt', rtopt, 'pa',pa,'pmax',pmax, 'pmaxindex', pmaxindex, 'begin', BEGIN_BLOCK, 'step', STEP, 'mcor', mcor, 'block_isodist_chk', block_isodist_chk, 'block_isodist_value', block_isodist_value, 'block_mass_model_chk', block_mass_model_chk, 'block_mass_error_thd', block_mass_error_thd);

if project.extnipals,
    project.deco_exnpls{blocknum} = decoresults;
else
    project.deco_mcr{blocknum} = decoresults;
    
end
deco_save_project();

end