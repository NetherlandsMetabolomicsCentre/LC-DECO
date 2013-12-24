function deco_estimateentropythresh(fileid)

global project MVERSION SVERSION;

if MVERSION <= SVERSION,    
    matname = [substr(char(project.files(fileid)), 0, -4), '.mat'];
    data = load(char(matname), '-mat');        
else
    matname = [project.files(fileid,1:end-4) '.mat'];
    data = load(char(matname), '-mat');    
end

project.maxentrpy = max(data.msetr);
project.entthresh = (mean(data.msetr) + std(data.msetr))/project.maxentrpy;

end