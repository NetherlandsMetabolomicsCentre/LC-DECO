function [xblockT, msvx, peaknrs, optc, opts, mcor] = deco_blockselectmasseswithisotopicdistributions(xblockT, msvx, peaknrs, block_isodist_value)
% Remember that c and s in this function stands for spectra = c, and
% concentration = s %

ch = 20;
minpkwidth = 3;
iso = block_isodist_value;
coeffch = 5;

spk = deco_spikechannelindex(xblockT, minpkwidth);

xblockT = xblockT(spk, :);
msvx = msvx(spk);

[m, n] = size(xblockT);
c0 = rand(m, peaknrs);
[c1, s1] = deco_mcr(xblockT, c0);

%xblockTd = abs(diff(xblockT, 1, 2));

xblockTd = deco_randomiseblock(xblockT);

[m, n] = size(xblockTd);
c0 = rand(m, peaknrs);
[c2, s2] = deco_mcr(xblockTd, c0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Experiments on the randomness of various intialisation modes
for k = 1:50

[m, n] = size(xblockT);
c0a = rand(m, peaknrs);
c0b = rand(m, peaknrs);
[c1a, s1a] = deco_mcr(xblockT, c0a);
[c1b, s1b] = deco_mcr(xblockT, c0b);


xblockTd = deco_randomiseblock(xblockT);
[m, n] = size(xblockTd);
[c2, s2] = deco_mcr(xblockTd, c0a);

for i = 1:peaknrs
    c1a(:, i) = c1a(:, i)./max(c1a(:, i));
    c1b(:, i) = c1b(:, i)./max(c1b(:, i));
    c2(:, i) = c2(:, i)./max(c2(:, i));
    ecab(:, i) = abs(c1a(:, i) - c1b(:, i));
    y =  ecab(ecab(:, i)>0, i)./max(ecab(ecab(:, i)>0, i));
    etrab(k, i) = -sum(y .* log(y))/size(y, 2);
    ecat(:, i) = abs(c1a(:, i) - c2(:, i));
    y =  ecat(ecat(:, i)>0, i)./max(ecat(ecat(:, i)>0, i));
    etrat(k, i) = -sum(y .* log(y))/size(y, 2);    
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[c1, c2, s1, s2] = deco_classifyms(c1, c2, s1, s2);

e2r = deco_fitline(c1, c2, xblockT, xblockTd, msvx);

peaknrs = size(c1, 2);
[a, b] = sort(e2r);

for i = 1: peaknrs
    tc = b(~isinf(a(:, i)), i);
    td = a(~isinf(a(:, i)), i);
    ntc = size(tc, 1);
    tv = ((c1(tc, i) - c2(tc, i)).^2)./c1(tc, i);

    nans = size(b(isinf(a(:, i)), i));
    c(:, i) = [tc; NaN(nans)];
    d(:, i) = [td; NaN(nans)];
    v(:, i) = [tv; NaN(nans)];
end

ed = deco_blockentropy(c, xblockT, ch);

pkindex = [];
for i = 1: peaknrs
    pd(:, i) = (1 - (1 - d(1:ch, i)./max(d(1:ch, i))) .* (1 - ed(1:ch, i)./max(ed(1:ch, i))));
    mct = c(pd(:, i)<iso, i);
    
    pkindex = [pkindex i];
%     if(mct(2)-mct(1) ~= 1)
%         display(['Carbon isotope no found: ' num2str(i)]);
%     else
%         pkindex = [pkindex i];
%     end
end

peaknrs = size(pkindex, 2);
mc = [];
optc = [];
opts = [];
for j = 1: peaknrs
    i = pkindex(j);
    mct = c(pd(:, i)<iso, i);
    x = xblockT(mct, :); 
    optct = c1(mct, i)./max(c1(mct, i));
    optst = x'/optct';
    optctt = zeros(size(msvx, 1), 1);
    optctt(mct, 1) = optct;
    optc = [optc; optctt'];
    opts = [opts optst];    
    mc = [mc; mct];
end

% [pd, pdi] = sort(pd);
% 
% mc = unique(mc);
% xblockT = xblockT(mc, :)';
% msvx = msvx(mc);

mcor = deco_masscorrelation(xblockT, msvx, peaknrs, optc, opts, coeffch);

end


function mcor = deco_masscorrelation(x, m, np, c, s, n)

mcor = zeros(n, np);

for i = 1:np
    [a, b] = sort(c(i, :), 'descend');
    s = size(a(a>0), 2);
    if (s<n)
        n = s;
    end
    
    xj = x(b(1: n), :);
    
    r = corrcoef(xj');
    mcor(1:n, i) = r(:, 1);
end

end

function rblk = deco_randomiseblock(blk)

rblk = blk;
[m, n] = size(blk);
index = fix(rand(n, 1)*n);
index = index(index>0);

rblk(:, 1: size(index)) = blk(:, index);
rblk(:, index) = blk(:,1: size(index));

end

function edata = deco_blockentropy(dindex, data, ch)

m = size(dindex, 2);

for i = 1:m
    for j = 1: ch
        d = data(dindex(j, i), :);
        y = d(d>0)./max(d(d>0));
        edata(j, i) = -sum(y .* log(y))/size(y, 2);
    end
end

end


function [cn1, cn2, sn1, sn2] = deco_classifyms(c1, c2, s1, s2)

[a1, b1] = max(c1, [], 1);
[a2, b2] = max(c2, [], 1);

[b1, x] = unique(b1);
c1 = c1(:, x);
s1 = s1(x, :);

[b2, x] = unique(b2);
c2 = c2(:, x);
s2 = s2(x, :);

k = size(b1, 2);
j = 1;
for i = 1: k
    if (any(b1(i) == b2))
        cn1(:, j) = c1(:, b1(i) == b1);
        sn1(j, :) = s1(b1(i) == b1, :);
        cn2(:, j) = c2(:, b1(i) == b2);
        sn2(j, :) = s2(b1(i) == b2, :);
        j = j + 1;
    end
end

end

function e2r = deco_fitline(c1, c2, xblockT, xblockTd, msvx)

[a1, b1] = max(c1, [], 1);
[a2, b2] = max(c2, [], 1);

x1 = diag(c1(b1, :));
y1 = diag(c2(b2, :));

[x2, b] = deco_isotopeindex(c1, xblockT, msvx);
k = size(c1, 2);
y2 = diag(c2(b, 1:k));
% y2 = deco_isotopeindex(c2, xblockTd);

m = (y1 - y2)./(x1 - x2);
c = (y1 - x1.*m);

k = size(c1, 2);
y2c = [];
e2r = [];
for i = 1: k
    y2c(:, i) = c1(:, i).*m(i) + c(i);
    e2r(:, i) = (y2c(:, i) - c2(:, i)).^2;
    l = size(e2r(:, i), 1);
    for j = 1: l
        e2r(j, i) = e2r(j, i)/c2(j, i);
    end
end
end

function [y, b] = deco_isotopeindex(c, xblockT, msvx)

c13vl = 1.001;
c13vh = 1.005;
k = size(c, 2);
y = zeros(k, 1);
b = zeros(k, 1);
for i = 1: k
    [a1, b1] = sort(c(:, i), 'descend');
    xblkt = xblockT(b1, :);
    r = corrcoef(xblkt');
    [a2, b2] = sort(r(:, 1), 'descend');
    m = msvx - msvx(b1(1));
    d = [];
    d = b2(((m(b1(b2)) >= c13vl) & (m(b1(b2)) <= c13vh)) & (b1(b2)>b1(1)));
    if (isempty(d))
        d = b2((b1(b2)>b1(1)));
    end
    y(i) = c(b1(d(1)), i);
    b(i) = b1(d(1));
%     tc = c(x(i)+1:end, i);
%     yt = tc(tc>0);
%     y(i) = yt(1);
end

end