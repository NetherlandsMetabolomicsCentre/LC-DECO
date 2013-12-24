function spk = deco_spikechannelindex(d, mw)

n = size(d, 2);
dw = [];
for i = 1:n-mw
    x = min(d(:, i: i+mw), [], 2);
    dw = [dw, x];
end
spk = any(dw, 2);

end