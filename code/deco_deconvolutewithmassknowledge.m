function [ctx, stx] = deco_deconvolutewithmassknowledge(xblock, msvx, BEGIN_BLOCK, s)

global project;
ns = project.nfiles; % number of sample files

% if(isempty(project.td))
    deco_locatetargetmassinblocks();
% end

targetdata = project.td;
[sn, mc] = size(xblock);

targetdata = locatetargetdatainblock(targetdata, BEGIN_BLOCK, sn, s);
targetdata = removedeconvolutedmass(s, msvx, targetdata);

ctx = [];
stx = [];

if(~isempty(targetdata))
    mcindex = locatemasschannelfromtarget(msvx, targetdata(:, 1));
    mcindex = mcindex(mcindex>0);
    
    nc = size(mcindex, 1);
    
    ctx = zeros(sn, nc);
    stx = zeros(nc, mc);
    oxblock = xblock;
    for i = 1: nc
        sinit = zeros(1, mc);
        sinit(1, mcindex(i)) = 1;
        xblock = supressblock(oxblock, mcindex(i));
        [ct, st, sdopt, numiter] = deco_als990(0, xblock, sinit, ns);
        [ctx(:, i), stx(i, :)] = deco_normalisemassspectra(ct, st);
        xblock = xblock - ct*st;
    end
end

end

function oxblock = supressblock(oxblock, mci)

sigpeak = max(oxblock(:, mci));
oxblock(:, (max(oxblock, [], 1)>sigpeak)) = 0;

end

function targetdata = removedeconvolutedmass(s, msvx, targetdata)

[a, b] = max(s, [], 2);
x = unique(msvx(b));

mcindex = locatemasschannelfromtarget(x, targetdata(:, 1));

targetdata = targetdata(mcindex==0);

end

function targetdata = locatetargetdatainblock(targetdata, BEGIN_BLOCK, sn, msvx, s)

ntargetfiles = size(targetdata, 2) - 1;
STEP = sn/ntargetfiles;

BEGIN = BEGIN_BLOCK;
END = BEGIN + STEP - 1;
x = [];
for i = 1:ntargetfiles
    y = targetdata((targetdata(:, i+1) >= BEGIN) & (targetdata(:, i+1) <= END), :);
    x = [x; y];
end

targetdata = unique(x, 'rows');
end

function mcindex = locatemasschannelfromtarget(msva, massid)

[a, b] = size(massid);
mcindex = zeros(a, 1);

for i = 1:a
    loc = find(fix(msva*10)==fix(massid(i)*10));
    if(~isempty(loc))
        [x1, y1] = min(abs(msva(loc)-massid(i)));
        loc = loc(y1);
        mcindex(i) = loc;
    end
end

end

function [xblock, m] = deco_blockselectmasses(xblock, m, NOISE_THRESHOLD)

tic = sum(xblock, 1);
mx = max(tic);
tic = tic / mx;
xblock = xblock(:,tic>=NOISE_THRESHOLD);
m = m(tic>=NOISE_THRESHOLD);

end

function [c1, s1] = deco_normalisemassspectra(c1, s1)

maxs = max(s1, [], 2);

[a, b] = size(maxs);

for i = 1:a
    s1(i, :) = s1(i, :)./maxs(i);
    c1(:, i) = c1(:, i).*maxs(i);
end

end