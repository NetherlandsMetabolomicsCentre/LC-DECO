function deco_locatetargetmassinblocks()

global project MVERSION SVERSION;
lcmsfiles = project.files;
nd = project.nfiles;

targetfile = project.targetfile;
targetdata = importdata(targetfile);
massid = targetdata(:, 1);
st = massid;

for i=1:nd
    if MVERSION<=SVERSION,
        matname = strcat(substr(char(lcmsfiles(i)), 0, -4),'_bcor.mat');
    else
        matname = [lcmsfiles(i,1:end-4),'_bcor.mat'];
    end
%     matname = strcat(substr(char(lcmsfiles(i)), 0, -4),'_bcor.mat');
    load(char(matname), '-mat');
    sn = locatepeaksfromtarget(msi, msva, massid);
    st = [st, sn];
end

project.td = st;
deco_save_project();

end

function sn = locatepeaksfromtarget(msi, msva, massid)

global project;

[a, b] = size(massid);
sn = zeros(a, 1);

for i = 1:a
    loc = find(fix(msva*10)==fix(massid(i)*10));
    if(~isempty(loc))
        [x1, y1] = min(abs(msva(loc)-massid(i)));
        loc = loc(y1);
        [x2, sn(i, :)] = max(msi(loc, :));
        sn(i, :) = sn(i, :) + project.minscan - 1;
    end
end

end