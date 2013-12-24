function [block_mass_model_chk,  block_mass_error_thd] = deco_modelmasserror(block)

global project;
if project.extnipals,
    decoresults = project.deco_exnpls{block};
else
    decoresults = project.deco_mcr{block};
end

block_mass_model_chk = decoresults.block_mass_model_chk;
block_mass_error_thd = decoresults.block_mass_error_thd;

end