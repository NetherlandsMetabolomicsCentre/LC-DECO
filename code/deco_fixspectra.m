function  [c1, s1, sdopt, numiter] = deco_fixspectra(block, x, npeaks, actfiles)
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
% S. Krishnan
% Determining component iteratively with appropriate seeding strategy
% Improved for peak selection
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%

[row, col] = size(x);
rv = zeros(npeaks, 1);

x1 = x;
i = 1;
c = zeros(row, 1);
xms = [];
while i <= npeaks
    x1(:, xms) = 0;
    [rt, ms] = find(x1 == max(max(x1)), 1, 'first');
    c(rt,i) = max(max(x1));
    is1 = c\x;
    display(['Deconvoluting peak: ' num2str(i)]);
    [c1, s1, sdopt, numiter] = deco_als990(block, x, is1, actfiles);
  
    dx = c1(:,i)*s1(i,:);
    [dxrt, dxms] = find(dx == max(max(dx)), 1, 'first');
    
    if(dxms ~= ms)
        xms = [xms; ms];
        display(['Automatically selected peak not fitted: ' num2str(i)]);
    end
    x1 = x - c1*s1;
    i = i + 1;
    initc = zeros(row, 1);
    c = [c1, initc];
end

[c1, s1] = deco_normalisemassspectra(c1, s1);

end


function [c1, s1] = deco_normalisemassspectra(c1, s1)

maxs = max(s1, [], 2);

[a, b] = size(maxs);

for i = 1:a
    if(maxs(i))
        s1(i, :) = s1(i, :)./maxs(i);
        c1(:, i) = c1(:, i).*maxs(i);
    end
end

end


% function  [c1, s1, sdopt, numiter] = deco_fixspectra(block, x, npeaks, actfiles)
% %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
% % S. Krishnan
% % Determining component iteratively with appropriate seeding strategy
% %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%
% 
% [row, col] = size(x);
% c = zeros(row, npeaks);
% rv = zeros(npeaks, 1);
% 
% x1 = x;
% %r = [];
% i = 1;
% while i <= npeaks
%     [mx, idx] = max(sum(x1,2));
%     [rt, ms] = find(x1 == max(max(x1)), 1, 'first');
%     c(idx,i) = max(max(x1));
%     is1 = c\x;
%     [c1, s1, sdopt, numiter] = deco_als990(block, x, is1, actfiles);
%     x1 = x - c1*s1;
%     if (any(any(c1(:,i)*s1(i,:))) == 0)
%         x1(:, ms) = 0;
%     else
%         %r(:, :, i) = x1;
%         i = i + 1;
%     end
% end
% 
% end