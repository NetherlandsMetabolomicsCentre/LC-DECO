function y = deco_readset()
%----------------------------------------------
% batch version of reading files 
% and converting it to a dbc file
%----------------------------------------------
resample.do       = 0;  % do resample this file
resample.start    = 0.0; % the resample start time
resample.end      = 0.0; % the resample end time 
resample.interval = 0.0; % the resample interval
masscorr          = 1.0; % mass correction factor

% read a set of spectra
% str='Read files';
% ht = waitbar(0,str);
filename_cdf = 'C:\Deco\deco_demo_data\LC-MS\E-Coli\samples\3b_11.cdf';
filename_dbc = 'C:\Deco\deco_demo_data\LC-MS\E-Coli\samples\3b_11.dbc';

%deco_lcmsbindata(filename_cdf);

[theMat_cdf,startmass,scantimes_cdf] = deco_cdf2mat(filename_cdf,1.0); % read cdf file

ntraces = size(theMat_cdf,1);
scantimes = scantimes_cdf;
version = 0.0;
resample.start = min(scantimes_cdf);
resample.end   = max(scantimes_cdf);
align =0;
spikes = 0; 

% calculate the minimum scantime per interval
interval = min(diff(scantimes_cdf));

resample.interval = interval;  
%resample
% here the data is restored in the dbc file                
theMat = theMat_cdf; %#ok<NASGU>
options.asym   = 0;
options.lambda = 0;
options.order  = 0;
options.gsize  = 0;
options.gmove  = 0;
options.gthresh=0;
options.basewin=0; 
save(filename_dbc,'theMat','theMat_cdf','startmass','scantimes','scantimes_cdf','resample','options','masscorr','align','spikes','masscorr','ntraces','version');                
clear 'theMat' 'startmass' 'scantimes_cdf' 'scantimes' 'theMat_cdf';           

% close(ht)

deco_baseline_set(filename_dbc);
y = 1;
end



