function [msv, msi, msva, mse] = deco_lcmsbindata(cdf_file, numscans)

%function [msv, msi, msva, mse] = deco_lcmsbindata()

%cdf_file = 'C:\Deco\deco_demo_data\LC-MS\PolarLipid\CDF\1PL-TRS-QC-04.cdf';

[snr, sidx, data, inst] = cdf_extract_d(cdf_file,'scan_number','scan_index','mass_values','intensity_values');

BEGIN = 1;
END = snr -1;
END = numscans;

msv = [];
msi = [];
mse = [];
msva = [];
um = unique(fix(data));

for i=1:size(um,1)

[ms, mi, am, ws] = lcms_massbinwnd(um(i), snr, sidx, data, inst, BEGIN, END);

en =[];
for j=1:size(ms,1)
    %mi(j,:) = (mi(j,:)/max(mi(j,:))).* ms(j,:);
    indx = find(ms(j,:)>0);
    dm(j,:) = zeros(1,size(ms,2));
    dm(j,indx) = am(j)*ones(1,size(indx,2)) - ms(j,indx);
    en(j) = deco_entropy(mi(j,:));
end
display(um(i));

msv = [msv; ms];
msi = [msi; mi];
msva = [msva; am];
mse = [mse; en'];

end

% IDXPLOT = 1;
% figure;
% hold on;
% scatter(1:snr-1, ms(IDXPLOT,:), '*', 'g');
% plot(mi(IDXPLOT,:), 'b');
% indx = find(dm(IDXPLOT,:)>0);
% scatter(indx, dm(IDXPLOT,indx), '*', 'm');
% %plot(dm(1,:)>0, 'k');
% % scatter(1:snr-1, ms(2,:), '+', 'k');
% % scatter(1:snr-1, ms(3,:), '>', 'y');
% % scatter(1:snr-1, ms(4,:), '<', 'm');
% % scatter(1:snr-1, ms(5,:), '^', 'r');
% % scatter(1:snr-1, ms(6,:), 'd', 'b');
% % scatter(1:snr-1, ms(7,:), 'p', 'c');
% %plot(mi(2,:));
% hold off;


% for i=1:size(ms,1);
% figure;
% hold on;
%     LL = ones(size(ms(i,:)))*(am(i)-CONST*ws(i));
%     MD = ones(size(ms(i,:)))*(am(i));
%     UL = ones(size(ms(i,:)))*(am(i)+CONST*ws(i));
%     plot(1:snr-1, LL,'g:');
%     plot(1:snr-1, MD,'r');    
%     scatter(1:snr-1, ms(i,:), '*');
%     plot(1:snr-1, UL,'g:');
% hold off;
% end

% mv = 338;
% wd = 86;
% mass = [];
% loc = [];
% cdf_file = 'C:\Deco\deco_demo_data\LC-MS\PolarLipid\CDF\1PL-TRS-QC-04.cdf';
% [snr, sidx, data, inst] = cdf_extract_d(cdf_file,'scan_number','scan_index','mass_values','intensity_values');
% bg = 2026;
% ed = bg+wd;
% [x, xi] = fillmass(sidx, data, mv, inst, bg, ed);
% [x, xi] = alignmat(x, xi);
% loc = [loc, size(x,1)];
% mass = [mass; x];
% 
% cdf_file = 'C:\Deco\deco_demo_data\LC-MS\PolarLipid\CDF\1PL-TRS-QC-05.cdf';
% [snr, sidx, data, inst] = cdf_extract_d(cdf_file,'scan_number','scan_index','mass_values','intensity_values');
% bg = 1981;
% ed = bg+wd;
% [x, xi] = fillmass(sidx, data, mv, inst, bg, ed);
% [x, xi] = alignmat(x, xi);
% loc = [loc, size(x,1)];
% mass = [mass; x];
% 
% cdf_file = 'C:\Deco\deco_demo_data\LC-MS\PolarLipid\CDF\1PL-TRS-QC-06.cdf';
% [snr, sidx, data, inst] = cdf_extract_d(cdf_file,'scan_number','scan_index','mass_values','intensity_values');
% bg = 2041;
% ed = bg+wd;
% [x, xi] = fillmass(sidx, data, mv, inst, bg, ed);
% [x, xi] = alignmat(x, xi);
% loc = [loc, size(x,1)];
% mass = [mass; x];
% 
% marker = ['*', '+', '^'];
% 
% for j=1:min(loc)
% figure;
% hold on;
% for i=1:3
%     scatter(1:wd+1, mass(j,:), marker(i));
%     j = j + loc(i);
% end
% hold off;
% end

end

function [ms, mi, m, s] = lcms_massbinwnd(mass_value, scan_number, scan_index, cdf_data, cdf_inst, BEGIN, END)

[ms, mi] = fillmass(scan_index, cdf_data, mass_value, cdf_inst, BEGIN, END);
[ms, mi] = alignmat(ms, mi);

nm = size(ms,1);
m = zeros(nm,1);
s = zeros(nm,1);
% mi = zeros(nm,1);
% ma = zeros(nm,1);
for i=1:nm
    nmid = find(ms(i,:));
    sms = ms(i, nmid);
    m(i) = median(sms);
    s(i) = medmad(sms,2);
end

end

function [m, in] = alignmat(m, in)

idm = find(m(end,:)>0,1);
mrf = m(:,idm);
uv = ones(size(mrf));

for j=1:size(m,2)
    tm = zeros(size(mrf));
    ti = zeros(size(mrf));
    mcid = find(m(:,j)>0);
    for i=1:size(mcid)
        [v, id] = min(abs(mrf - m(mcid(i),j)*uv));
        tm(id) = m(mcid(i),j);
        ti(id) = in(mcid(i),j);
    end
    m(:,j) = tm;
    in(:,j) = ti;
end

end

function [y, z] = fillmass(sidx, data, mv, inst, bg, ed)
for i=bg:ed
    idx = sidx(i)+1:sidx(i+1);
    midx = find(fix(data(idx)) == mv);
    j(i) = length(midx);
    y(1:length(midx),i-bg+1) = data(sidx(i)+midx);
    z(1:length(midx),i-bg+1) = inst(sidx(i)+midx);
end

end


function y = fillscan(data)

ACY = 1e2;
sidxb = 670;
wd = 20;

data = data*ACY;
minid = fix(min(data));
maxid = fix(max(data));
mass = zeros(wd,maxid);

for i=sidxb:sidxb+wd-1
    idx = sidx(i)+1:sidx(i+1);
    massidx = single(fix(data(idx)));
    mass(i-sidxb+1,massidx) = single(data(idx)./ACY);
end

y = mass;

end