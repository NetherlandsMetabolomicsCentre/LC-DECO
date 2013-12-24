% These are not-used code %
function [xblock, m] = deco_blockselectmasses(xblock, m, NOISE_THRESHOLD, BLOCK_ENT_THRESHOLD)

% [a, b] = size(xblock);
% enb = [];
% for i=1:b
%     enb(i) = deco_entropy(xblock(:,i));
% end
% 
% xblock = xblock(:,enb<BLOCK_ENT_THRESHOLD);
% m = m(enb<BLOCK_ENT_THRESHOLD);

tic = sum(xblock);
mx = max(tic);
tic = tic / mx;
xblock = xblock(:,tic>=NOISE_THRESHOLD);
m = m(tic>=NOISE_THRESHOLD);

end

% [bms1, bms2, bms3, msv] = deco_lcmsbinmultipledata('8374_AQ_QC_02-2500_bcor.mat', '8374_AQ_QC_04-2500_bcor.mat', '8374_AQ_QC_06-2500_bcor.mat');
% 
% deco_savedata('8374_AQ_QC_02-2500.mat', bms1, msv);
% deco_savedata('8374_AQ_QC_04-2500.mat', bms2, msv);
% deco_savedata('8374_AQ_QC_06-2500.mat', bms3, msv);

% [lcmsmat, msv] = deco_lcmsdata('1PL-TRS-QC-04-3000_prepro.mat', '1PL-TRS-QC-05-3000_prepro.mat', '1PL-TRS-QC-06-3000_prepro.mat');
% 


% [a, b] = size(lcmsmat);
% samplesize = a/ns;
% 
% datablock = [];
% 
% for i=1:ns,
%     bg = (i-1) * samplesize + BEGIN;
%     ed = bg + BLOCKSIZE - 1;
%     datablock = [datablock; lcmsmat(bg:ed, :)];
% end