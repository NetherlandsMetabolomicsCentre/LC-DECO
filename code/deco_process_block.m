function [copt, sopt] = deco_process_block(block, totblock, npeaks)
global project;
numfiles = project.nfiles;
pw = size(totblock, 1)/(numfiles*4);
usemasses = size(totblock, 2);
blocksize = project.blocksize;
   
%stop= 0;
%while stop==0
    sp = zeros(npeaks,pw*4,'single');
    delta=(3.5/(npeaks+1));
    init_pos=floor(([1:npeaks]*delta+0.25)*pw); % space peaks
    for sp_init = 1:npeaks,
        sp(sp_init,:) = deco_makegauss(1:pw*4,init_pos(sp_init),pw*1/6); % create initiation gaussian peaks
    end
    idx = 1:project.nfiles; % index to the files
    actfiles=project.nfiles; % count the number of actual files to include
    thesescans=1:pw*4*numfiles;
    %s = zeros(actfiles,npeaks,length(usemasses),'single');
    s = zeros(actfiles,npeaks,usemasses,'single');
    c = zeros(4*pw,npeaks,'single');
    for part=1:length(idx), % for each individual file
        % s = spectrum (height per mass peak) (ncompounds,nmass)
        % c = concentration per spectrum (4* pw, ncompounds)
        % sp= estimated concentration profiles
        [c(:,:),s(idx(part),:,:)]=deco_mcr(totblock((idx(part)-1)*4*pw+1:idx(part)*4*pw,:),sp');
    end
    %compact the spectrum dimension into a single set of spectra
    s=(squeeze(median(s,1))); % s = height per mass peak
    %clear c; % remove the concentrations
    sopt=zeros(npeaks,size(totblock,2),'single');
    copt=zeros(4*pw*numfiles,npeaks,'single');
    areaopt=zeros(npeaks,numfiles);

%     [copt(thesescans,:),sopt(:,:),sdopt,suggest_numpeaks,dummy,ni]=...
%         deco_als99(block,totblock(thesescans,:),s,actfiles);
    [copt(thesescans,:), sopt(:,:), sdopt, numiter] = deco_als990(block, totblock(thesescans,:), s,actfiles);
    
    s = sum(sopt,2); % calculate tic
    
    
    
%     stop=1;
%     if autoreduce>0
%         for i=1:npeaks-1
%             f1 = find(sopt(i,:)>0.05);
%             for j=i+1:npeaks
%                 f2 = find(sopt(j,:)>0.05);
%                 fi = intersect(f1,f2);
%                 if size(fi,2)==size(f2,2) | size(fi,2)==size(f2,2)
%                     %sprintf('Block %d (%d %d)[%d %d %d]\n',block,i,j,size(f1,2),size(f2,2),size(fi,2))
%                     %disp(['equal compounds' num2str(i) ' ' num2str(j)]);
%                     stop=0;
%                 end
%             end
%         end
%     end
%     if stop==0
%         npeaks = npeaks - 1;
%     end
    %autoreduce
%end
quality = [];
pn = [];
pmax = zeros(npeaks,project.nfiles);
for peak=1:npeaks,
    for file=1:numfiles
        tmpConc = copt((file-1)*4*pw+1:file*4*pw,peak);
        warning off Matlab:divideByZero
        [eV,sV] = deco_gaussfit(1:4*pw,tmpConc);
        warning on Matlab:divideByZero
        %calculate the area of the peak
        areaopt(peak,file)=sum(copt((file-1)*4*pw+1:file*4*pw,peak))*s(peak); % calculate the area under the peak
        [mx,mp] = max(tmpConc);
        if areaopt(peak,file)>0
            quality(peak,file).err = (eV/areaopt(peak,file))*100; % percent error value of peak fit
        else
            quality(peak,file).err=0;
        end
        quality(peak,file).symm = sV; % peak symmetry
        quality(peak,file).mxpos  = mp; % position of maximum
        pmax(peak,file) = mp;
    end
    pn{peak} = sprintf('pk(%d)%d',block,peak);
end
% incl = ones(npeaks,1); % which peaks are to be included in global struct
% decoresults=struct('copt',copt,'sopt',sopt,'sdopt',sdopt,'areaopt',areaopt,'ni',ni,'usemass',usemasses,'inc',incl,'quality',quality);
% % store the decoresults
% project.deco{block}=decoresults;
% project.deco{block}.pmax = pmax; % store the peak maxima
% project.deco{block}.pnames = pn;
% np = npeaks;
end