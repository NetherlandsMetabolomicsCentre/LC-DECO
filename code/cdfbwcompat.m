function res = cdfbwcompat(fileName)

%ncid = netcdf.open(fileName,'NC_NOWRITE');


[ncid,status] = mexnc('OPEN',fileName,'NC_NOWRITE');

% [numdims, numvars, numglobalatts, unlimdimID] = netcdf.inq(ncid);


[numdims, numvars, numglobalatts, unlimdimID] = mexnc('INQ',ncid);

res.numdims = numdims;
res.globalatts = numglobalatts;
res.unlimID = unlimdimID;
res.numvars = numvars;

vr = repmat(struct('name',[],'xtype',[],'dimids',[],'numatts',[],'varid',[],'value',[]),numvars,1);
for i=1:numvars,
    
%     [vr(i).name, vr(i).xtype, vr(i).dimids, vr(i).numatts] = netcdf.inqVar(ncid,i-1);
    [vr(i).name, vr(i).xtype, vr(i).dimids, vr(i).numatts] = mexnc('INQ_VAR',ncid,i-1);
    
%     vr(i).varid = netcdf.inqVarID(ncid,vr(i).name);
%     vr(i).value = netcdf.getVar(ncid,vr(i).varid);

tp = 'GET_VAR_DOUBLE';
%%
% [data,status] = mexnc('GET_VAR_DOUBLE',ncid,varid);
%       [data,status] = mexnc('GET_VAR_FLOAT', ncid,varid);
%       [data,status] = mexnc('GET_VAR_INT',   ncid,varid);
%       [data,status] = mexnc('GET_VAR_SHORT', ncid,varid);
%       [data,status] = mexnc('GET_VAR_SCHAR', ncid,varid);
%       [data,status] = mexnc('GET_VAR_UCHAR', ncid,varid);
%       [data,status] = mexnc('GET_VAR_TEXT',  ncid,varid);


switch(vr(i).xtype)
    case 0
        tp='GET_VAR_DOUBLE'; %#ok<NASGU>
    case 1 
        tp='GET_VAR_FLOAT';%#ok<NASGU>
    case 2 
        tp='GET_VAR_INT';%#ok<NASGU>
    case 3 
        tp='GET_VAR_SHORT';%#ok<NASGU>
    case 4 
        tp='GET_VAR_SCHAR';%#ok<NASGU>
    case 5 
        tp='GET_VAR_UCHAR';%#ok<NASGU>
    case 6 
        tp='GET_VAR_TEXT';%#ok<NASGU>
        
        
end

      vr(i).varid = mexnc('INQ_VARID',ncid,vr(i).name);
     vr(i).value = mexnc(tp,ncid,vr(i).varid);
 



end


res.vars = vr;
res.fileName = fileName;

vrs = {};
for i=1:length(res.vars)
    vrs(i) = {res.vars(i).name};
end

scanidx = strmatch('scan_index',vrs);
ptnridx = strmatch('point_count',vrs);
rtidx = strmatch('scan_acquisition_time',vrs); 
mzidx = strmatch('mass_values',vrs);
intidx = strmatch('intensity_values',vrs);

res.snr = length(res.vars(scanidx).value);
res.sidx = res.vars(scanidx).value;
res.ptnr = sum(res.vars(ptnridx).value);
res.rt = res.vars(rtidx).value;
res.data = res.vars(mzidx).value;
res.inst = res.vars(intidx).value;


%netcdf.close(ncid);
status = mexnc('CLOSE',ncid)
