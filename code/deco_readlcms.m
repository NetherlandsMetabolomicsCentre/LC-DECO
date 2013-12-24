function y = deco_readlcms()

ns = 1; % number of sample files
np = 5; % number of peaks

% bidx = 400;
% lidx = 2000;
% step = 500;
% wsize = 200;

x = [];

dbcname(1,:) = 'C:\Deco\deco_demo_data\LC-MS\E-Coli\samples\1b_11.dbc';
load('-mat',dbcname(1,:),'theMat','options', 'theMat_cdf');
z = theMat(940:1080,:);
x = [x;z];

% dbcname(2,:) = 'C:\Deco\deco_demo_data\LC-MS\E-Coli\samples\1b_11.dbc';
% load('-mat',dbcname(1,:),'theMat','options', 'theMat_cdf');
% z = theMat(510:610,:);
% x = [x;z];

% dbcname(3,:) = 'C:\Deco\deco_demo_data\LC-MS\E-Coli\samples\serie2\2a_11.dbc';
% load('-mat',dbcname(1,:),'theMat','options', 'theMat_cdf');
% z = theMat(1350:1550,:);
% x = [x;z];
% 
% dbcname(4,:) = 'C:\Deco\deco_demo_data\LC-MS\E-Coli\samples\serie2\2b_11.dbc';
% load('-mat',dbcname(1,:),'theMat','options', 'theMat_cdf');
% z = theMat(1350:1550,:);
% x = [x;z];
% 
% dbcname(5,:) = 'C:\Deco\deco_demo_data\LC-MS\E-Coli\samples\serie3\3a_11.dbc';
% load('-mat',dbcname(1,:),'theMat','options', 'theMat_cdf');
% z = theMat(1350:1550,:);
% x = [x;z];
% 
% dbcname(6,:) = 'C:\Deco\deco_demo_data\LC-MS\E-Coli\samples\serie3\3b_11.dbc';
% load('-mat',dbcname(1,:),'theMat','options', 'theMat_cdf');
% z = theMat(1350:1550,:);
% x = [x;z];


[c1, s1] = deco_fixspectra(0, x, np, ns);


% dbcname(2,:) = 'C:\Deco\deco_demo_data\LC-MS\E-Coli\samples\serie1\1b_14.dbc';
% dbcname(3,:) = 'C:\Deco\deco_demo_data\LC-MS\E-Coli\samples\serie2\2a_14.dbc';
% dbcname(4,:) = 'C:\Deco\deco_demo_data\LC-MS\E-Coli\samples\serie2\2b_14.dbc';
% dbcname(5,:) = 'C:\Deco\deco_demo_data\LC-MS\E-Coli\samples\serie3\3a_14.dbc';
% dbcname(6,:) = 'C:\Deco\deco_demo_data\LC-MS\E-Coli\samples\serie3\3b_14.dbc';

% for k=bidx:step:lidx,
%     eidx = k + step;
%     
%     sftidx = getAlignIndex(dbcname,k,eidx,wsize);
%     
%     x = [];
%     
%     load('-mat',dbcname(1,:),'theMat','options', 'theMat_cdf');
%     z = theMat(sftidx(1):sftidx(1)+(eidx-k),:);
%     x = [x;z];
%     
%     load('-mat',dbcname(2,:),'theMat','options', 'theMat_cdf');
%     z = theMat(sftidx(2):sftidx(2)+(eidx-k),:);
%     x = [x;z];
%     
%     load('-mat',dbcname(3,:),'theMat','options', 'theMat_cdf');
%     z = theMat(sftidx(3):sftidx(3)+(eidx-k),:);
%     x = [x;z];
%     
%     load('-mat',dbcname(4,:),'theMat','options', 'theMat_cdf');
%     z = theMat(sftidx(4):sftidx(4)+(eidx-k),:);
%     x = [x;z];
%     
%     load('-mat',dbcname(5,:),'theMat','options', 'theMat_cdf');
%     z = theMat(sftidx(5):sftidx(5)+(eidx-k),:);
%     x = [x;z];
%     
%     load('-mat',dbcname(6,:),'theMat','options', 'theMat_cdf');
%     z = theMat(sftidx(6):sftidx(6)+(eidx-k),:);
%     x = [x;z];
%     
%     [c1, s1] = deco_fixspectra(0, x, np, ns);
%     
%     dirn = ['C:\Deco\deco_demo_data\LC-MS\E-Coli\decoresults\tp14\', int2str(k),'-',int2str(eidx)];
%     mkdir(dirn);
%     
%     save([dirn, '\c.mat'],'c1','-mat');
%     save([dirn, '\s.mat'],'s1','-mat');
%     save([dirn, '\x.mat'],'x','-mat');
% end

end

function sftidx = getAlignIndex(dbcname,bidx,eidx,wsize)

load('-mat',dbcname(1,:),'theMat','options', 'theMat_cdf');
xref = theMat(bidx:eidx,:);
sxref = sum(theMat(bidx:eidx,:),2);

fnr = size(dbcname,1);

sftidx = zeros(fnr,1);
sftidx(1) = bidx;
for j=2:fnr,
    
    load('-mat',dbcname(j,:),'theMat','options', 'theMat_cdf');
    z = theMat;
    lidx = size(z,1);
    
    for i=bidx-wsize:(eidx+wsize-(eidx-bidx))
        sz = sum(z(i:i+(eidx-bidx),:),2);
        sdiff(i) = sum(abs(sxref - sz));
    end
    
    [v, idx] = min(sdiff(bidx-wsize:end));
    sftidx(j) = idx + (bidx-wsize);
    %plot(sdiff);
   
end

end

