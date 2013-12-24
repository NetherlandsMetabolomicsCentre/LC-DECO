function deco_visualisemassmodelerr(block, file_id)

global project;
if project.extnipals,
    decoresults = project.deco_exnpls{block};
else
    decoresults = project.deco_mcr{block};
end
begin_block = decoresults.begin-project.minscan+1;

matname = [substr(char(project.files(file_id)), 0, -4), '_bcor.mat'];

% [begin, er2, msva] = load(matname, 'BEGIN', 'er2', 'msva', '-mat');

load(matname, 'BLOCK_BEGIN', 'er2', 'msva', '-mat');

er = er2(~(isnan(er2) | isinf(er2)));
m = msva(~(isnan(er2) | isinf(er2)));

er = er/max(er);

if (BLOCK_BEGIN == begin_block)
    titlestr = ['mass chromatogram: ', char(project.files(file_id))];
    xaxessstr = 'scan number';
    yaxesstr = 'Model Error';
    figure; scatter(m, er);
    xlabel(xaxessstr);
    ylabel(yaxesstr);
    title(titlestr);
end

end