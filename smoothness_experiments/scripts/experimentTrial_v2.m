
function [] = experimentTrial_v2(subj_id, type, startInd, fn)

% experimentTrial_v2(subj_id, type)
% Or: experimentTrial_v2(subj_id, type, startInd, fn)

%% EXAMPLES:
% To begin a 'practice' trial for subject test_person:
% experimentTrial_v2('test_person','practice')

% Or for example, to continue previous file 'test_person_static_v0' at pair index 6 use:
% experimentTrial_v2('test_person', 'static', 6, 'test_person_practice_v0')

%% FUNCTION DESCRIPTION
% The function runs an 2AFC experiment trial on a set of numerically-indexed input pairs,
% using Matlab's UI key events. The testing window must be open while testing is in progress.  
%
% subj_id: the name or ID of the subject being tested, which will be the
% directory name for the output file.
%
% type: a string, e.g. 'practice' or 'static' which will be appended to
% output filenames. 'practice' will initiate a trial with 10 pairs for a
% practice session; any other type will initiate a trial with the full 48
% pairs. 
%
% startInd [optional, defaults to 1]: the starting index for the trials. Use this
% only if you want to continue a previous session, using the fn argument to
% input the filename you want to continue. 
%
% fn [optional]: name of an existing file which you want to test on; used only 
% if you want to continue a previous session (WARNING: will
% overwrite existing file if the start index is not set properly)


%% Experimeter Controls: 
% For each trial, a pair of numbers will appear on the screen to indicate
% the trial pair. 
% The 's' key can be used to play a tone and indicate readiness for the
% trial to begin. 

% The subject must press down both arrow keys, and then release one arrow
% key (followed by the other) to indicate their selection. After this 
% sequence, a new trial pair will appear on the screen. 

% The 'r' key can be used to revert one trial backwards, i.e. to repeat the
% previous trial. The previous trial will be overwritten.



%% Initialize the texture names and the pairs 
%          (**For this experiment only**)
if ~strcmp(type, 'practice')
    pairs = pair_list([1:8],[9:11]);
else
    pairs = [9, 11; 11,9; 11,10; 1,11; 11,4; 1,4; 8,1; 8,6; 6,3];
end

tex_names = {'20/16, diam. 0.1', '20/16, diam. 0.3', '20/16, diam. 0.5', ...
    '16/16, diam 0.1', '16/16, diam. 0.3', '20/16, diam. 0.5', ...
    '12/16 diam. 0.1', '12/16, diam 0.3', ...
    '12/16 standard', '16/16 standard', '20/16 standard'}'


close all

if nargin < 2
         type = 'no_type';
end
if nargin < 3
        startInd = 1;
end

pairList = pairs;
pairList = pairList(:,1:2);

%% Selects the output directory 
homedir= uigetdir;  
RAW_DATA_PATH = fullfile(homedir,subj_id);
if ~exist(RAW_DATA_PATH)
    mkdir(RAW_DATA_PATH)
end
fileName = initializeList(RAW_DATA_PATH, subj_id, type)

%% Initialize variables
keysPressed = {};
listLock=false;
currentInd=startInd;
inTrial=false;
trialStartTime=-1;

outMat = [pairList, -1*ones(length(pairList),3)];
if nargin==2
    save(strcat(fileName(1:end-4), '_tex_names.mat'), 'tex_names');
end

if nargin==3
     disp('Invalid inputs.')
     return
end
if nargin>=4
    pairInd = startInd;
    exFileName = fullfile(RAW_DATA_PATH,fn); 
    pl = struct2array(load(exFileName));
    if ~strcmp(type,'triple')
        pairList = pl(:,1:2);
    else
        pairList = pl(:,1:3);
    end
    
    outMat = pl;
    fileName = exFileName
end
save(fileName,'outMat');


%% Create the basic UI, and then begin
S.fh = figure('units','pixels',...
              'position',[0 0 500 250],...
              'menubar','none',...
              'name',fileName,...
              'numbertitle','off',...
              'resize','off',...
              'color', 'g',...
              'keypressfcn',@fh_kpfcn, 'keyreleasefcn',@fh_krfcn);
S.tx = uicontrol('style','text',...
                 'units','pixels',...
                 'FontSize', 16,...
                 'position',[50 100 400 100],...
                 'HorizontalAlignment', 'center',...
                 'fontweight','bold'); 
 S.txprev = uicontrol('style','text',...
                 'units','pixels',...
                 'FontSize', 12,...
                 'position',[50 100 400 50],...
                 'HorizontalAlignment', 'left');     
  S.txcur = uicontrol('style','text',...
                 'units','pixels',...
                 'FontSize', 14,...
                 'position',[50 60 400 50],...
                 'HorizontalAlignment', 'left',...
                 'fontweight','bold');  
  S.txnext = uicontrol('style','text',...
                 'units','pixels',...
                 'FontSize', 12,...
                 'position',[50 20 400 50],...
                 'HorizontalAlignment', 'left');  

guidata(S.fh,S)          

numbered_tex_names = tex_names;
for i=1:length(tex_names)
    numbered_tex_names{i} = [num2str(i) '. ' numbered_tex_names{i}];
end
numbered_tex_names = ['Texture Names'; ' '; numbered_tex_names];
%set(S.tx,'string',[numbered_tex_names; ' '; 'not started'])
set(S.tx,'string','TESTING NOT STARTED')
%set(S.txprev, 'string', 'Previous pair:');
%set(S.txcur, 'string', 'Current pair:');
%set(S.txnext, 'string', 'Next pair:');

pairList
dispStart()




%% UI functions to detect key events

function [] = fh_krfcn(H,E)          
% Figure keypressfcn
S = guidata(H);
P = get(S.fh,'position');
%set(S.tx,'string',[numbered_tex_names; '.'; 'in progress'])
set(S.tx,'string', 'TESTING IN PROGRESS')

removeKey(E.Key);
if inTrial
    if strcmp(E.Key,'rightarrow')
        endTrial(E.Key)
    end
    if strcmp(E.Key,'leftarrow')
        endTrial(E.Key)
    end
end
end


function [] = fh_kpfcn(H,E)          
% Figure keypressfcn
S = guidata(H);
P = get(S.fh,'position');
added = addKey(E.Key);
if added
    if keyPressed('rightarrow') && keyPressed('leftarrow')
        %begin the trial
        beginTrial()
    end
    if keyPressed('r')
        disp('reverting backwards');
        currentInd=max(1,currentInd-1);
        outMat(currentInd,end-2:end) = [-1, -1, -1]; %= [outMat; [pairList(pairInd,:), leftReleased, rightReleased, responseTime]];
        save(fileName,'outMat');
        dispNextEntry();
    end
    if keyPressed('s')
        soundTone(.4,500);
    end
    if keyPressed('d')
        outMat
    end
end
    %if both arrow keys are pressed
    
end

    function b = addKey(k)
        b=0;
        while listLock
            print 'lock'
        end
        listLock=true;
        if(~keyPressed(k))
            keysPressed = [keysPressed, k];
            b=1;
        end
        listLock=false;
    end

    function [] = removeKey(k)
        while listLock
            print 'lock'
        end
        listLock=true;
        goods = find(~ismember(keysPressed, k));
        if length(goods)==0
            keysPressed={};
        else
        keysPressed = keysPressed{goods};
        end
        listLock=false;
    end
    
    function p= keyPressed(k)
        p= (length(find(ismember(keysPressed, k)))>0);
    end
        
function []=dispStart()
    
    disp(sprintf('\n'));
    disp('--------------------');
    disp(['Number of Trials: ' num2str(length(pairList))]);
    disp('Initializing testing');
    disp('--------------------')

    dispNextEntry();
end


%% Function to display text on screen
%helper to display current entry
    function dispNextEntry()
        pairInd=currentInd;
        totalLength =  (length(pairList));
        if pairInd > totalLength
            disp('Testing is complete.')
        else
            disp(sprintf('\n'));
            disp(['Trial #: ', num2str(pairInd), ' of ', num2str(totalLength)]); 
            disp('------------------');
            disp(pairList(pairInd,:));     
        end
        
    end

    function beginTrial()
        inTrial=true;
        trialStartTime=GetSecs;
    end

    function endTrial(k)
        totalTime = GetSecs-trialStartTime;
        disp([k,' released; Time (s): ', num2str(totalTime)])
        inTrial=false;
        if totalTime<0.45
            disp(sprintf('\n'));
            disp('WARNING: The time interval was suspiciously short.');
            disp('Trial was not recorded and will be repeated.');
        else
            outMat(currentInd,(end-2):end) = [strcmp(k,'leftarrow'), strcmp(k,'rightarrow'), totalTime];
            save(fileName,'outMat');
            currentInd=currentInd+1;
        end
        dispNextEntry()
    end
end



%% Helper function to create sequentially numbered filenames, i.e. V0, then V1, V2, etc.
function fileName = initializeList(RAW_DATA_PATH, name, type)
    %Initialize the filename
    fileName = strcat(name, '_', type);
    fileName = fullfile(RAW_DATA_PATH, fileName);

    %check,and append 'V0' or 'V1', etc if necessary to avoid overwriting
    fileName = strcat(fileName,'_v0');
    file_v = 0;
    while exist(strcat(fileName,'.mat'))>0
      file_v = file_v+1;
      fileName = strcat(fileName(1:end-3),'_v', num2str(file_v));
    end
    fileName = strcat(fileName,'.mat');
end



