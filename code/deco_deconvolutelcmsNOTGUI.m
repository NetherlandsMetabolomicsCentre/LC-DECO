function deco_deconvolutelcmsNOTGUI()

% cdf_file = 'C:\Deco\deco_demo_data\LC-MS\Tomato\3 times same sample powder\F003014.cdf';
% 
% [msv, msi, msva, mse] = deco_lcmsbindatablock(cdf_file,1250);
% 
% save -mat F003014.mat msv msi msva mse;
% 
% clear msv msi msva mse;
% 
% load -mat F003014.mat;

% CHROM_ENT_THRESHOLD = 3.5; % Entropy threshold for mass chromatogram alignment
% deco_lcmsbaselinecorrection('F002943.mat',CHROM_ENT_THRESHOLD);
% deco_lcmsbaselinecorrection('F002976.mat',CHROM_ENT_THRESHOLD);
% deco_lcmsbaselinecorrection('F003014.mat',CHROM_ENT_THRESHOLD);


LEVEL = 2;     % noise level corrector in estimate peaks
NOISE_THRESHOLD = 1e-3;
BEGIN_CHROM = 700;
STEP = 150;
END_CHROM = 1250;
ns = 3; % number of sample files
RESIDUE_LIMIT = 1e-6;
%datamatname = ['F002943_bcor.mat';'F002976_bcor.mat';'F003014_bcor.mat'];
datamatname = {'F002943.cdf','F002976.cdf','F003014.cdf'};

for BEGIN = BEGIN_CHROM:STEP:END_CHROM,
    END = BEGIN + STEP;
    [xblock, msvx] = deco_createblock(datamatname, BEGIN, STEP);
    [xblock, msvx] = deco_blockselectmasses(xblock, msvx, NOISE_THRESHOLD);
%     sc = deco_significantchannels(xblock, RESIDUE_LIMIT);
%     xblock = xblock(:, sc);
%     msvx = msvx(sc);
    np = deco_estimate_lcmsblock(xblock, LEVEL);
    [c, s] = deco_fixspectra(0, xblock, np, ns);
    %deco_savelcmsresults(c, s, xblock, msvx, BEGIN,END);
end

end


function [xblock, m] = deco_blockselectmasses(xblock, m, NOISE_THRESHOLD)

tic = sum(xblock);
mx = max(tic);
tic = tic / mx;
xblock = xblock(:,tic>=NOISE_THRESHOLD);
m = m(tic>=NOISE_THRESHOLD);

end

function deco_savelcmsresults(c, s, x, m, BEGIN,END)

dirn = ['C:\Deco\deco_demo_data\LC-MS\Tomato\3 times same sample powder\TNO-DECO results\', int2str(BEGIN),'-',int2str(END)];
mkdir(dirn);

save([dirn, '\lcmsresult.mat'],'c', 's', 'x', 'm', 'BEGIN', 'END','-mat');

end


function deco_lcmsbaselinecorrection(data, CHROM_ENT_THRESHOLD)

load(data, '-mat');

msi = msi(mse<=CHROM_ENT_THRESHOLD,:);
msva = msva(mse<=CHROM_ENT_THRESHOLD);

matname = substr(data, 0, -4);

save([matname, '_bcor.mat'],'msi', 'msva','-mat');

end

function deco_savedata(dataname, msi, msva)

matname = substr(dataname, 0, -4);

save([matname, '_prepro.mat'], 'msi', 'msva','-mat');

end


function np = deco_estimatepeaks(data, ns, BEGIN, BLOCKSIZE, LEVEL)

[a, b] = size(data);
samplesize = a/ns;

for i=1:ns,
    bg = (i-1) * samplesize + BEGIN;
    ed = bg + BLOCKSIZE - 1;
    np(i) = deco_estimate_lcmsblock(data(bg:ed, :), LEVEL);
end

np = max(np);

end



