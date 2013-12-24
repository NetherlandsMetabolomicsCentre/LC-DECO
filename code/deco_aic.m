%function aic = deco_aic(r, k)

function aic = deco_aic()

% [m, n] = size(r);
% sr = r .* r;
% rss = sum(sum(sr ./ max(max(sr))));
% aic = 2*k + (m+n)*log(rss);

load -mat rnc.mat;

[m, n, mitr] = size(r);

for i = 1: mitr
    ri = r(:, :, i);
    sr = ri .* ri;
    rss(i) = sum(sum(sr ./ max(max(sr))));
    aic(i) = 2*i + (m*n)*log(rss(i));
    figure;
    plot(ri);
    xlabel(i);
end

end