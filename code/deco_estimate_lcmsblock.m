function numsig = deco_estimate_lcmsblock(block,level)

ssq = sum(sum((deco_mncn(block)).^2));
simblock=randn(size(block))*(ssq/numel(block)).^(1/2);

[a,b]=size(block);
if a > b
    block2 = block'*block;
    sblock = simblock'*simblock;
else
    block2 = block*block';
    sblock = simblock*simblock';
end

% METHOD using eig is much faster (factor 2.5) than using svd(x,0)
values =(sort(real(abs(eig(block2))),'descend'));
% do eig on the estimated (simulated) noise data
s_sim = (sort(real(abs(eig(sblock))),'descend'));

%estimate the number of peaks for eigenvalues above noise eigenvalue
numsig=1;
while (values(numsig) > s_sim(numsig)*level)
    numsig=numsig+1;
end
   
end
    