function deco_exportresults()

global project MVERSION SVERSION;

depth = 5;
if project.extnipals,
    rdeco = project.deco_exnpls;
    ext = 'npls';
else
    rdeco = project.deco_mcr;
    ext = 'mcr';
end

fid = fopen([project.basename, ext, '_area.xls'],'w+t');
nfiles = project.nfiles;
% fprintf(fid, 'Block \tPeak \tM1 \tRAb.M1 \tM2 \tRAb.M2 \tM3 \tRAb.M3 \tM4 \tRAb.M4 \tM5 \tRAb.M5 \tRt(mts) \tScan');
fprintf(fid, 'Block \tPeak \tM1 \tRAb.M1 \tM2 \tM2-M1 \tRAb.M2 \tM3 \tM3-M1 \tRAb.M3 \tM4 \tM4-M1 \tRAb.M4 \tM5 \tM5-M1 \tRAb.M5 \tRt(mts) \tScan');
% fprintf(fid, 'Block \tPeak \tM1 \tRAb.M1 \tmc.M1 \tM2 \tM2-M1 \tRAb.M2 \tmc.M2 \tM3 \tM3-M1 \tRAb.M3 \tmc.M3 \tM4 \tM4-M1 \tRAb.M4 \tmc.M4 \tM5 \tM5-M1 \tRAb.M5 \tmc.M5 \tRt(mts) \tScan');
for i = 1:nfiles
    fprintf(fid, '\t');
    if MVERSION<=SVERSION,
        filename = substr(char(project.files{i}), 0, -4);
    else
        filename = project.files(i,1:end-4);
    end
    fprintf(fid, '%s', filename);
    
end
fprintf(fid, '\n');

nblks = size(rdeco, 2);
for i = 1:nblks
    exportblockinfo(fid, i, rdeco{i}, depth, nfiles);
    %exportblockinfodeep(fid, i, rdeco{i}, depth);
end

fclose(fid);

end

function exportblockinfo(fid, nblk, blkres, depth, nfiles)
npks = size(blkres.c, 2);
ns = size(blkres.s, 2);

for i = 1: npks
    fprintf(fid, '%u\t', nblk);
    fprintf(fid, '%u\t', i);
    [ms, msindex] = max(blkres.s(i, :));
    [s, sindex] = sort(blkres.s(i, :), 'descend');
    ds = min(depth, size(sindex, 2));
%     mcori = blkres.mcor(:, i);
    for j = 1: ds
        if (blkres.msvx(sindex(j)))
            fprintf(fid, '%.3f\t', blkres.msvx(sindex(j)));
            if (j>1)
            fprintf(fid, '%.3f\t', blkres.msvx(sindex(j))-blkres.msvx(sindex(1)));
            end
            fprintf(fid, '%.3f\t', s(j)/s(1));
%             fprintf(fid, '%.3f\t', mcori(j));
        end
    end
    fprintf(fid, '%.2f\t', median(blkres.rt(blkres.pmaxindex(:, i)))/60);
    fprintf(fid, '%u\t', blkres.begin -1 + round(median(blkres.pmaxindex(:, i))));
    for j = 1:nfiles
        fprintf(fid, '%d\t', blkres.pa(j, i));
    end
    fprintf(fid, '\n');
end
end

function exportblockinfodeep(fid, nblk, blkres, depth)
npks = size(blkres.c, 2);
ns = size(blkres.s, 2);

for i = 1: npks
    fprintf(fid, '%u\t', nblk);
%     fprintf(fid, '%u\t', ns);
    fprintf(fid, '%u\t', i);
    [s, sindex] = sort(blkres.s(i, :), 'descend');
    ds = min(depth, size(sindex, 2));
    mcori = blkres.mcor(:, i);
    for j = 1: ds
        if (blkres.msvx(sindex(j)))
            fprintf(fid, '%.3f\t', blkres.msvx(sindex(j)));
            fprintf(fid, '%.3f\t', s(j)*100/s(1));
            fprintf(fid, '%.3f\t', mcori(j));
        end
    end
    fprintf(fid, '\n');
end
end

%             c: [755x4 single]
%             s: [4x22 single]
%          msvx: [22x1 double]
%            rt: [5x151 double]
%            pa: [5x4 double]
%          pmax: [5x4 double]
%     pmaxindex: [5x4 double]
%         begin: 1
%          step: 150