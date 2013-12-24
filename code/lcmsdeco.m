function varargout = lcmsdeco(varargin)
% LCMSDECO M-file for lcmsdeco.fig
%      LCMSDECO, by itself, creates a new LCMSDECO or raises the existing
%      singleton*.
%
%      H = LCMSDECO returns the handle to a new LCMSDECO or the handle to
%      the existing singleton*.
%
%      LCMSDECO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LCMSDECO.M with the given input arguments.
%
%      LCMSDECO('Property','Value',...) creates a new LCMSDECO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before lcmsdeco_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to lcmsdeco_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help lcmsdeco

% Last Modified by GUIDE v2.5 21-Dec-2011 16:55:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @lcmsdeco_OpeningFcn, ...
                   'gui_OutputFcn',  @lcmsdeco_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before lcmsdeco is made visible.
function lcmsdeco_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to lcmsdeco (see VARARGIN)

% Choose default command line output for lcmsdeco
handles.output = hObject;
global project MVERSION SVERSION

SVERSION = 76;
v = ver('matlab');
MVERSION = str2double(strrep(v.Version,'.',''));

project.basename    = 'deco-lcms1';
project.maxscan     = []; % maximum scan numbers
project.minscan     = []; % minumum scan numbers
project.sdir        = ''; % files directory
project.files       = []; % filenames
project.entthresh   = 0;  % entrophy threshold
project.blocksize   = '100'; % block size for deconvolution
project.noiselevel  = '1e-1'; % Noise level for peak estimation
project.noisethresh = '2'; % Noise threshold for mass channels
project.deco_mcr    = cell(0,0); % the deco resuls in mcr-als
project.deco_exnpls = cell(0,0); % the deco resuls in ext.nipals
project.nfiles      = []; % Number of files
project.maxblks     = []; % Number of blocks
project.extnipals   = 0;  % default not Ext. NIPALS, instead MCR-ALS
project.maxentrpy   = 0;  % Maximum entropy value, only for normalisation purposes
project.target      = 0;  % target files to be included or not; default is no target
project.td          = []; % stores the target mass location information
project.targetfile  = ''; % target file directory

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes lcmsdeco wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = lcmsdeco_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% New project
global project;
[a, prjname]=deco_projectname('filename',project.basename); % collect answer and new projectname
if a(1)=='O'
    project.basename = prjname;
    set(handles.projectname,'String',project.basename); 
end


% --- Executes on button press in loadproject.
function loadproject_Callback(hObject, eventdata, handles)
% hObject    handle to loadproject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Load project
[prj,pdir]=uigetfile({'*.prj','Project files (*.prj)'},'Open project Files');
if (prj==0) % no files selected
    return;
end
load('-mat',[pdir prj], 'project');
set(handles.projectname,'String',project.basename);
set(handles.maxscan,'String',num2str(project.maxscan));
set(handles.minscan,'String',num2str(project.minscan));
set(handles.noisethresh,'String',num2str(project.noisethresh));
set(handles.blocksize,'String',num2str(project.blocksize));
set(handles.noiselevel,'String',num2str(project.noiselevel));
set(handles.listfiles,'String',project.files);
set(handles.maxblks,'String',project.maxblks);
set(handles.extnipals,'Value',project.extnipals);
set(handles.estentpy,'Value', project.entthresh);
set(handles.target_chk,'Value', project.target);
set(handles.edit_targetfilename,'String', project.targetfile);

display(project.files);


function projectname_Callback(hObject, eventdata, handles)
% hObject    handle to projectname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of projectname as text
%        str2double(get(hObject,'String')) returns contents of projectname as a double
% New project name


% --- Executes during object creation, after setting all properties.
function projectname_CreateFcn(hObject, eventdata, handles)
% hObject    handle to projectname (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in loadfiles.
function loadfiles_Callback(hObject, eventdata, handles)
% hObject    handle to loadfiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global project MVERSION SVERSION;

[files,dir]=uigetfiles('*.cdf','NetCDF files');
    
if size(files,2)==0 % cancel pressed
    return;
end

project.sdir      = dir; % files directory
project.files     = files; % filenames

if MVERSION<=SVERSION,            
    project.nfiles    = size(files,2);  % number of files
else
    project.nfiles    = size(files,1);  % number of files
end

project.blocksize = str2double(get(handles.blocksize,'String'));
project.blocksize = str2double(get(handles.blocksize,'String'));
project.noisethresh = str2double(get(handles.noisethresh,'String'));
project.noiselevel = str2double(get(handles.noiselevel,'String'));
project.extnipals = get(handles.extnipals,'Value');
maxscan = str2double(get(handles.maxscan,'String'));
if isnan(maxscan)
    project.maxscan = deco_maximumscanlcms();
else
    project.maxscan = str2double(get(handles.maxscan,'String'));
end
set(handles.maxscan,'String',num2str(project.maxscan));

minscan = str2double(get(handles.minscan,'String'));
if isnan(minscan)
    project.minscan = 1;
else
    project.minscan = str2double(get(handles.minscan,'String'));
end
set(handles.minscan,'String',num2str(project.minscan));
set(handles.listfiles,'String',project.files);
deco_save_project();

% --- Executes on button press in binning.
function binning_Callback(hObject, eventdata, handles)
% hObject    handle to binning (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global project;
project.maxscan   = str2double(get(handles.maxscan,'String'));
project.minscan   = str2double(get(handles.minscan,'String'));

% deco_lcmsscannumber2retentiontime();

deco_multiplefilebinning();
id = get(handles.listfiles,'Value');
deco_estimateentropythresh(id);
set(handles.estentpy,'Value', project.entthresh);
deco_save_project();


% --- Executes on button press in baseline.
function baseline_Callback(hObject, eventdata, handles)
% hObject    handle to baseline (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global project;
project.entthresh = get(handles.estentpy,'Value');
deco_multiplefilebaselinecorrection();

% --- Executes on button press in deconvolution.
function deconvolution_Callback(hObject, eventdata, handles)
% hObject    handle to deconvolution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global project;
project.blocksize = str2double(get(handles.blocksize,'String'));
project.noisethresh = str2double(get(handles.noisethresh,'String'));
project.noiselevel = str2double(get(handles.noiselevel,'String'));
project.extnipals = get(handles.extnipals,'Value');
project.target = get(handles.target_chk,'Value');
deco_deconvolutelcms();
if project.extnipals,
    project.maxblks = size(project.deco_exnpls, 2);
else
    project.maxblks = size(project.deco_mcr, 2);
end
set(handles.maxblks,'String',project.maxblks);
deco_save_project();
display('Deconvolution completed');


function blocknr_Callback(hObject, eventdata, handles)
% hObject    handle to blocknr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of blocknr as text
%        str2double(get(hObject,'String')) returns contents of blocknr as a double


% --- Executes during object creation, after setting all properties.
function blocknr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to blocknr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in inspect.
function inspect_Callback(hObject, eventdata, handles)
% hObject    handle to inspect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global project;
block = str2double(get(handles.blocknr,'String'));
project.extnipals = get(handles.extnipals,'Value');
peaknrs = deco_peaknrs(block);

[block_isodist_chk,  block_isodist_value] = deco_isodist(block);
set(handles.checkbox_isodist,'Value',block_isodist_chk);
set(handles.isodist_val,'Value',block_isodist_value);

[block_mass_model_chk,  block_mass_error_thd] = deco_modelmasserror(block);
set(handles.mass_model_chk,'Value',block_mass_model_chk);
set(handles.mass_error_thd,'Value',block_mass_error_thd);

set(handles.peaknrs,'String',peaknrs);
deco_lcmsinspectresults(block);

% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
deco_exportresults();
display('export');

% --- Executes on button press in saveproject.
function saveproject_Callback(hObject, eventdata, handles)
% hObject    handle to saveproject (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% save project and results
deco_save_project();
display('save');



function maxscan_Callback(hObject, eventdata, handles)
% hObject    handle to maxscan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxscan as text
%        str2double(get(hObject,'String')) returns contents of maxscan as a double


% --- Executes during object creation, after setting all properties.
function maxscan_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxscan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function blocksize_Callback(hObject, eventdata, handles)
% hObject    handle to blocksize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of blocksize as text
%        str2double(get(hObject,'String')) returns contents of blocksize as a double


% --- Executes during object creation, after setting all properties.
function blocksize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to blocksize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function noisethresh_Callback(hObject, eventdata, handles)
% hObject    handle to noisethresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of noisethresh as text
%        str2double(get(hObject,'String')) returns contents of noisethresh as a double


% --- Executes during object creation, after setting all properties.
function noisethresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to noisethresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function noiselevel_Callback(hObject, eventdata, handles)
% hObject    handle to noiselevel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of noiselevel as text
%        str2double(get(hObject,'String')) returns contents of noiselevel as a double


% --- Executes during object creation, after setting all properties.
function noiselevel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to noiselevel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listfiles.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listfiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listfiles contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listfiles


% --- Executes during object creation, after setting all properties.
function listfiles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listfiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in listfiles.
function listfiles_Callback(hObject, eventdata, handles)
% hObject    handle to listfiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in displaychro.
function displaychro_Callback(hObject, eventdata, handles)
% hObject    handle to displaychro (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global project MVERSION SVERSION;
id = get(handles.listfiles,'Value');
if MVERSION<=SVERSION,
title = ['mass chromatogram: ', char(project.files{id})];
else
    title = ['mass chromatogram: ', char(project.files(id,1:end))];
end
xaxes = 'scan number';
yaxes = 'TIC';

BEGIN = project.minscan;
END = project.maxscan;
if MVERSION<=SVERSION,

    matname = [substr(char(project.files(id)), 0, -4), '.mat'];
    data = load(char(matname), '-mat');


else
    fNames = project.files;    
    matname = fNames(id,1:end-4);
    data = load(char(matname), '-mat');
    %     BEGIN = 1;
    %     END = length(data.vars(9));

end
xaxisindex = BEGIN:END;
deco_displayresults(xaxisindex, sum(data.msi, 1), title, xaxes, yaxes);


% --- Executes on button press in displaychrmbaseln.
function displaychrmbaseln_Callback(hObject, eventdata, handles)
% hObject    handle to displaychrmbaseln (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global project MVERSION SVERSION; 
id = get(handles.listfiles,'Value');
xaxes = 'scan number';
yaxes = 'TIC';

if MVERSION<=SVERSION,    
    matname = [substr(char(project.files(id)), 0, -4), '.mat'];
else
    matname = [char(project.files(id,1:end-4)) '.mat'];
end
data = load(char(matname), '-mat');
project.entthresh = get(handles.estentpy,'Value');
entthresh = project.entthresh;
idx = data.msetr<=(entthresh*project.maxentrpy);
title = ['mass chromatogram: ', char(project.files(id)), ', Threshold: ', num2str(entthresh)];
BEGIN = project.minscan;
END = project.maxscan;
xaxisindex = BEGIN:END;
deco_displayresults(xaxisindex, sum(data.msi(idx, :), 1), title, xaxes, yaxes);



function maxblks_Callback(hObject, eventdata, handles)
% hObject    handle to maxblks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxblks as text
%        str2double(get(hObject,'String')) returns contents of maxblks as a double


% --- Executes during object creation, after setting all properties.
function maxblks_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxblks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in extnipals.
function extnipals_Callback(hObject, eventdata, handles)
% hObject    handle to extnipals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of extnipals


% --- Executes on slider movement.
function estentpy_Callback(hObject, eventdata, handles)
% hObject    handle to estentpy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function estentpy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to estentpy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in deconvoluteblock.
function deconvoluteblock_Callback(hObject, eventdata, handles)
% hObject    handle to deconvoluteblock (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global project;
peaknrs = str2double(get(handles.peaknrs,'String'));
blocknr = str2double(get(handles.blocknr,'String'));
project.extnipals = get(handles.extnipals,'Value');
project.noisethresh = str2double(get(handles.noisethresh,'String'));
project.noiselevel = str2double(get(handles.noiselevel,'String'));
[BEGIN, STEP] = deco_getbeginandstep(blocknr);
BLOCK_REDO = 1;
block_isodist_chk = get(handles.checkbox_isodist,'Value');
block_isodist_value = get(handles.isodist_val,'Value');

block_mass_model_chk = get(handles.mass_model_chk,'Value');
block_mass_error_thd = str2double(get(handles.mass_error_thd,'String'));

project.target = get(handles.target_chk,'Value');
deco_deconvoluteblock(BLOCK_REDO, blocknr, BEGIN, STEP, peaknrs, block_isodist_chk, block_isodist_value, block_mass_model_chk, block_mass_error_thd);

function peaknrs_Callback(hObject, eventdata, handles)
% hObject    handle to peaknrs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of peaknrs as text
%        str2double(get(hObject,'String')) returns contents of peaknrs as a double


% --- Executes during object creation, after setting all properties.
function peaknrs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to peaknrs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function minscan_Callback(hObject, eventdata, handles)
% hObject    handle to minscan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of minscan as text
%        str2double(get(hObject,'String')) returns contents of minscan as a double


% --- Executes during object creation, after setting all properties.
function minscan_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minscan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_isodist.
function checkbox_isodist_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_isodist (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_isodist


% --- Executes on slider movement.
function isodist_val_Callback(hObject, eventdata, handles)
% hObject    handle to isodist_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function isodist_val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to isodist_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in mass_model_chk.
function mass_model_chk_Callback(hObject, eventdata, handles)
% hObject    handle to mass_model_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of mass_model_chk


% --- Executes on button press in visualise_masserror.
function visualise_masserror_Callback(hObject, eventdata, handles)
% hObject    handle to visualise_masserror (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global project;
block = str2double(get(handles.blocknr,'String'));
file_id = get(handles.listfiles,'Value');
deco_visualisemassmodelerr(block, file_id);


function mass_error_thd_Callback(hObject, eventdata, handles)
% hObject    handle to mass_error_thd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of mass_error_thd as text
%        str2double(get(hObject,'String')) returns contents of mass_error_thd as a double


% --- Executes during object creation, after setting all properties.
function mass_error_thd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mass_error_thd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in target_chk.
function target_chk_Callback(hObject, eventdata, handles)
% hObject    handle to target_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of target_chk


% --- Executes on button press in pushbutton_targetfile.
function pushbutton_targetfile_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_targetfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global project;
[trg, tdir] = uigetfile({'*.csv','Target files (*.csv)'},'Open target files');
if (trg==0) % no files selected
    return;
end
project.targetfile = [tdir trg];
set(handles.edit_targetfilename,'String', trg);


function edit_targetfilename_Callback(hObject, eventdata, handles)
% hObject    handle to edit_targetfilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_targetfilename as text
%        str2double(get(hObject,'String')) returns contents of edit_targetfilename as a double


% --- Executes during object creation, after setting all properties.
function edit_targetfilename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_targetfilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


