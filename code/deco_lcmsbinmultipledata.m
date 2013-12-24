function [mbindata, binmsva] = deco_lcmsbinmultipledata(msix, msvax, ns)

MSCUTOFF = 1e-3; % for HR-LC
% MSCUTOFF = 0.1; % Dionex for bacteria, low resolution
[msvax, index] =  deco_colsorted(msvax, 'ascend', 1);
msix = msix(index, :);
mavad = [MSCUTOFF; abs(diff(msvax(:,1)))];

mbindata = [];
for i=1:ns
    bindata = single(zeros(size(msix)));
    bindata(msvax(:,2)==i,:) = msix(msvax(:,2)==i,:);
    bindata = deco_reassignmassindex(bindata, mavad, msvax, MSCUTOFF, i);
    mbindata = [mbindata; bindata'];
end

binmsva = msvax(mavad>=MSCUTOFF);

end


function bindata = deco_reassignmassindex(bindata, mavad, msvax, MSCUTOFF, ID)

a0 = find(mavad<MSCUTOFF & msvax(:,2)==ID);

a = size(a0);
for i=1:a
    cr = find(mavad(1:a0(i))>=MSCUTOFF,1,'last');
    bindata(cr,:) = bindata(a0(i),:);
end

bindata(mavad<MSCUTOFF,:) = [];

end


function [y, index] = deco_colsorted(x, order, col)

[xcol, index] = sort(x(:,col), order);
y = x(index, :);

end