function [xblock, m] = deco_blockselectmasses(xblock, m, NOISE_THRESHOLD)

tic = sum(xblock, 1);
mx = max(tic);
tic = tic / mx;
xblock = xblock(:,tic>=NOISE_THRESHOLD);
m = m(tic>=NOISE_THRESHOLD);

end
