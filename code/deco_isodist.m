function [block_isodist_chk,  block_isodist_value] = deco_isodist(block)

global project;
if project.extnipals,
    decoresults = project.deco_exnpls{block};
else
    decoresults = project.deco_mcr{block};
end

block_isodist_chk = decoresults.block_isodist_chk;
block_isodist_value = decoresults.block_isodist_value;

end