function dionextest(filename, thd, index)

[ndata, rxnRemoveList, alldata] = xlsread('Deconvoluted_data_Vs_target_list.xlsx');

% m_h = floor(ndata(:, 3)); % ((m_h)+)
% m_na = floor(ndata(:, 4)); % (m+na+)

m_h = unique(ndata(:, 3)); % ((m_h)+)
m_na = unique(ndata(:, 4)); % (m+na+)

data = load(filename);

msv = data.msv;
msi = data.msi;

adt = m_na; % change here for which adduct you choose (either m_h or m_na)

rw = [];
for j = 1: size(adt)
    for i = 1: size(msv, 2)
        a = find(floor(msv(:, i)) == floor(adt(j)));        
        rw = [rw; a];
        rw = unique(rw);
    end
end

b = [];
for i = 1:size(rw)
    if(find(msi(rw(i), :)>thd))
        b = [b; rw(i)];
    end
end

display(b);
% figure; plot(msi(b, :)');

for i = index: size(b)
    ll = max(msi(b(i), :))*0.1;
    hl = max(msi(b(i), :))*0.9;
   
    msvt = msv(b(i), (msi(b(i), :) > ll & msi(b(i), :) < hl));
    a = find(floor(adt) == unique(floor(msvt)));
    plot(msi(b(i), :));
    display(['the mass is ' num2str(unique(floor(msvt)))]);
    return;
    
%     if (size(a) == 1)
%         im = [adt(a) msvt];
%         name = [filename '.xls'];
%         xlswrite(name, im, 'data', strcat('A',num2str(i+1)));
%     end
    
end

end