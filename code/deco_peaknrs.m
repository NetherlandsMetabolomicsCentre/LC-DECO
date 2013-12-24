function peaknrs = deco_peaknrs(block)

global project;
if project.extnipals,
    decoresults = project.deco_exnpls{block};
else
    decoresults = project.deco_mcr{block};
end

peaknrs = decoresults.peaknrs;

end