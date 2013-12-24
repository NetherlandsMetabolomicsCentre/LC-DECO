function [xi, mi, mai, er2] = deco_modelmass(x, m, ma, tol)

mc = size(x, 1);
er2 = inf(mc, 1);
p1 = inf(mc, 1);
p0 = inf(mc, 1);

for i=1:mc
    xt = x(i, :);
    mt = m(i, :);
    [er2(i), p1(i), p0(i)] = modelmc(xt, mt);
end

tol = max(er2(~(isnan(er2) | isinf(er2))))*tol;

et = er2(~(isnan(er2) | isinf(er2))); 

xt = x(~(isnan(er2) | isinf(er2)), :);
xi = xt(et<tol, :);

mt = m(~(isnan(er2) | isinf(er2)), :);
mi = mt(et<tol, :);

mait = ma(~(isnan(er2) | isinf(er2)));
mai = mait(et<tol);

end

function [fte2, p1, p0] = modelmc(xt, mt)

fte2 = inf;
p1 = inf;
p0 = inf;

x1 = xt(:, xt>0);
x1 = x1./max(x1);

m1 = mt(:, xt>0);
m0 = median(m1(:, x1>0.7));

ym = (m1 - m0).*(m1 - m0);
logym = log(ym);
logym(isinf(abs(logym))) = 0;
logym = logym./max(abs(logym));

xm = x1;
p = polyfit(xm, logym, 1);
if (isinf(p) | isnan(p))
    return;
end
f = polyval(p, xm);

expf = exp(f);
expfn = expf/max(abs(expf));
iexpfn = 1-expfn;

fte2 = (x1 - iexpfn).^2;
fte2 = sum(fte2, 2);
p1 = p(1);
p0 = p(2);

% display(fte2);
% figure; scatter(xm, logym);
% figure; hold on; plot(x1); plot(1-expfn);
% figure; plot(1-expfn);
% figure; plot(xt);

end