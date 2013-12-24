function hrlcmsfig(msi, ni)

[a, b] = size(msi(358, :));

figure; hold on; h = scatter(1, msi(358, 1)); set(h, 'marker','d', 'markeredgecolor', ni(1, :)', 'markerfacecolor', ni(1, :)); 

for i = 2: b
    scatter(i, msi(358, i)); set(h, 'marker','d', 'markeredgecolor', ni(i, :)', 'markerfacecolor', ni(i, :)); 
end

end