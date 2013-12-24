function [BEGIN, STEP] = deco_getbeginandstep(blocknr)

global project;
if project.extnipals,
    decoresults = project.deco_exnpls{blocknr};
else
    decoresults = project.deco_mcr{blocknr};
end

BEGIN = decoresults.begin;
STEP = decoresults.step;

end