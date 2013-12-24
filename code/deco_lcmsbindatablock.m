function [msv, msi, msva, msetr, rt] = deco_lcmsbindatablock(cdf_file, numscans, minscan)

global MVERSION SVERSION;

if MVERSION<=SVERSION
    [snr, sidx, ptnr, rt, data, inst] = cdf_extract_d(cdf_file,'scan_number','scan_index', 'point_number', 'scan_acquisition_time', 'mass_values','intensity_values');
else
    A = cdfbwcompat(cdf_file);
    %snr = length(A.vars(5).value);
    sidx = A.sidx;
    ptnr = A.ptnr;
    rt = A.rt;
    data = A.data;
    inst = A.inst;
    
end
sidx = [sidx; double(ptnr)];
beginwnd = minscan;
enwnd = numscans;

BEGIN = beginwnd;
END = enwnd;

msv = [];
msi = [];
msetr = [];
msva = [];
um = unique(fix(data));

% for i=1:size(um,1)
% 
% [ms, mi, am, ws] = lcms_massbinwnd(um(i), sidx, data, inst, BEGIN, END);
% 
% if (isnan(am))
%     display('Nan');
% end
% 
% en =[];
% msf = [];
% for j=1:size(ms,1)
%     indx = find(ms(j,:)>0);
%     dm(j,:) = zeros(1,size(ms,2));
%     dm(j,indx) = am(j)*ones(1,size(indx,2)) - ms(j,indx);
%     en(j) = deco_entropy(mi(j,:));
% end
% display(um(i));
% 
% msv = [msv; ms];
% msi = [msi; mi];
% msva = [msva; am];
% msetr = [msetr; en'];
% 
% end

for i=1:size(um,1)
    
    [ms, mi, am, ws] = lcms_massbinwnd(um(i), sidx, data, inst, BEGIN, END);
    
    if (isnan(am))
        display('Nan');
    end
    
    en =[];
    msf = [];
    for j=1:size(ms,1)
        indx = find(ms(j,:)>0);
        
        if MVERSION<=SVERSION,
            dm(j,:) = zeros(1,size(ms,2));
            dm(j,indx) = am(j)*ones(1,size(indx,2)) - ms(j,indx);
        else % do nothing...
            
        end
        
        en(j) = deco_entropy(mi(j,:)); %#ok<AGROW>
    end
    display(um(i));
    msv = [msv; ms]; %#ok<AGROW>
    msi = [msi; mi];%#ok<AGROW>
    msva = [msva; am];%#ok<AGROW>
    msetr = [msetr; en'];%#ok<AGROW>
end

end

function [ms, mi, m, s] = lcms_massbinwnd(mass_value, scan_index, cdf_data, cdf_inst, BEGIN, END)

CHANNEL_INTENSITY_THRESHOLD = 1e-1;
minpkwidth = 3;

[ms, mi] = fillmass(scan_index, cdf_data, mass_value, cdf_inst, BEGIN, END);

if(size(ms, 1) == 0) 
    ms = [];
    mi = [];
    m = [];
    s = [];
    return;
end
    
[ms, mi] = alignmat(ms, mi);

[ms, mi] = deco_blockselectmasses(ms, mi, CHANNEL_INTENSITY_THRESHOLD);

[m, s, ms, mi] = deco_normdataforbin(ms, mi);

spk = deco_spikechannelindex(mi, minpkwidth);

mi = mi(spk, :);
ms = ms(spk, :);
m = m(spk);
s = s(spk);

end

function [m, s, ms, mi] = deco_normdataforbin(ms, mi)

actlow = 0.1;
acthigh = 0.9;

[a, b] = size(mi);
nmi = zeros(a, b);
m = zeros(a, 1);
s = zeros(a, 1);
nmindex = [];

for i = 1: a
    nmi(i, :) = mi(i, :)./max(mi(i, :));
    mx = ms(i, (nmi(i, :) >= 0.1 & nmi(i, :) <= 0.9));
    if (size(mx, 2) > 0)
        m(i) = median(mx);
        s(i) = medmad(mx,2);
    else
        nmindex = [nmindex; i];
    end
end

m(nmindex, :) = [];
s(nmindex, :) = [];
ms(nmindex, :) = [];
mi(nmindex, :) = [];

end

function [ms, mi] = deco_blockselectmasses(ms, mi, CHANNEL_INTENSITY_THRESHOLD)

len = size(mi,2);
mi2 = mi .* mi;
mirms = sqrt(sum(mi2,2)./len);
smi = mirms ./ (max(mirms));

mi = mi(smi>=CHANNEL_INTENSITY_THRESHOLD,:);
ms = ms(smi>=CHANNEL_INTENSITY_THRESHOLD,:);

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
global MVERSION SVERSION;

% for i=bg:ed
%     idx = sidx(i)+1:sidx(i+1);
%     midx = find(fix(data(idx)) == mv);
%     j(i) = length(midx);
%     y(1:length(midx),i-bg+1) = data(sidx(i)+midx);
%     z(1:length(midx),i-bg+1) = inst(sidx(i)+midx);
% end

y = [];
z = [];
for i=bg:ed
    idx = sidx(i)+1:sidx(i+1);
    midx = find(fix(data(idx)) == mv);
    j(i) = length(midx);
    
    if MVERSION<=SVERSION,
        y(1:length(midx),i-bg+1) = data(sidx(i)+midx);
        z(1:length(midx),i-bg+1) = inst(sidx(i)+midx);
    else
        %if (~isempty(midx)),
        y(1:length(midx),i-bg+1) = data(sidx(i)+int32(midx));
        z(1:length(midx),i-bg+1) = inst(sidx(i)+int32(midx));
        % else
        %             y(1:size(y,1),i-bg+1) = data(sidx(i)+int32(midx));
        %             z(1:size(y,1),i-bg+1) = inst(sidx(i)+int32(midx));
        % end
    end
end

end