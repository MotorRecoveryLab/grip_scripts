%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
 
% Author:Seda Bilaloglu
% Contact:seda.bilaloglu@nyumc.org 
% Last Update: November 3, 2014
% 
%A script to process force data for Cup Controller Experiment
%
%Modified by: Chelsea Tymms, tymms@cs.nyu.edu
%Last update: Dec 11, 2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
close all 
clc 
clear all  
 
homedir= uigetdir;  

subj_paths = dir(fullfile(homedir,'/'))
sp_name = {subj_paths.name}

%Select a subject directory 
for s ={sp_name{3:end}}
    direct1  = char(fullfile(homedir,s))
    %direct1  = char(fullfile(homedir,s,'/Tegaderm/SR_old'))
    %direct2 = char(fullfile(homedir,s,'/BareHands/SR_old'))
for direct = {direct1}
     direct = char(direct)
    [pathstr,name,ext] = fileparts(direct);  
[pa,na,ex] = fileparts(pathstr);  
[paa,naa,exx] = fileparts(pa);  
[paaa,subject,exxx] = fileparts(paa);  
[paaaa,bb,exxxx] = fileparts(paaa);
cd(fullfile(pathstr)) 

filesforce = dir(char(fullfile(pathstr,'*.txt')));    
 
 result=zeros(114,7);

params2 = [];

for ll=1:25; %IMPORT THE DATA for each trial for this subject
disp(ll)
close all

filename = filesforce(ll).name;
disp(filename)
A = importdata(filesforce(ll).name);
capname = filename(14);
weight = filename(9:11);
trial_id = strcat(capname, '_',weight);

for m=1:1:size(A.data,2);
ii= find(isnan(A.data(:,m))); 
A.data(ii,m)= zeros(size(ii));  
end   
  
time=A.data(:,1); 
fz1=A.data(:,10);  
fz2=A.data(:,11);  
fy1=A.data(:,12); 
fy2=A.data(:,13);  

switch_val=-50*A.data(:,end);  
peakfinder(switch_val);
switch_peaks = peakfinder(switch_val);
switch_peaks = time(switch_peaks);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%only do this if the peaks can't be found automatically
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% fig1=figure;
% plot(switch_val, 'b') 
% hold on
% plot(fz1,'r' );   
% hold on; 
% 
% title('Please choose the switch peaks') 
% hold on
% dcm_obj1 = datacursormode(fig1);
% set(dcm_obj1,'DisplayStyle','datatip',...
% 'SnapToDataVertex','off','Enable','on')
% 
% disp('Click line to display a data tip, then press Return.')
% % Wait while the user does this.
% pause 
% c_info1 = getCursorInfo(dcm_obj1);
% close  
% 
% switch_peaks = [c_info1.DataIndex]
% switch_peaks = switch_peaks(end:-1:1)/2000
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%Otherwise, manually choose the baseline, start and end for the trial
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

fig15=figure(15);   
 
plot( time,fz1,'r' );   
hold on
plot( time,fz2,'m' );  
hold on
plot(time,fy1, 'c' );   
hold on
plot(time,fy2, 'b' );  
legend('fz1','fz2', 'fy1', 'fy2')

for i=[1:2:length(switch_peaks)]
    if i+1 > length(switch_peaks)
        break
    end
    harea = area([switch_peaks(i), switch_peaks(i+1)], [10,10]);
    set( harea, 'FaceColor', 'y')
    alpha(.2)
end

title(strcat('Trial:',ll,'  Please select the start of baseline and end of trial. '));
grid     

dcm_obj15 = datacursormode(fig15);
set(dcm_obj15,'DisplayStyle','datatip',...
    'SnapToDataVertex','off','Enable','on') 
 
disp('Click line while holding alt to select data points. Then press Return.')
% Wait while the user does this.
pause  

c_info15 = getCursorInfo(dcm_obj15); 

data_end=2000*c_info15(1).Position(1,1);  
data_start=2000*c_info15(2).Position(1,1);  

baseline(ll)=.1;  

%If 2 points are selected, then first is the start and also the baseline, and the
%second is the end. 

%If 3 points are selected, the first is baseline, second is start, and
%third is end.

if size(c_info15,2) ==3
    baseline(ll)=c_info15(3).Position(1,1);  
else
baseline(ll)=c_info15(2).Position(1,1);  
end
baseline(ll)=round(baseline(ll)*2000); 
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if(data_end<data_start)
    temp = data_end;
    data_end=data_start;
    data_start=temp;
end
    

%Double-check that the selected "start" falls within an area where the sensor
%is down. Otherwise we need to delete the first peak in order to switch the
%up and down areas.
for i=[1:2:length(switch_peaks)]
    if data_start/2000 < switch_peaks(i+1) && data_start/2000 > switch_peaks(i)
        break
    end
    if data_start/2000 < switch_peaks(i+2) && data_start/2000 > switch_peaks(i+1)
        disp('Switching automatic up/down intervals');
        figure(16);   
        plot( time,fz1,'r' );   
        hold on
        plot( time,fz2,'m' );  
        hold on
        plot(time,fy1, 'c' );   
        hold on
        plot(time,fy2, 'b' );  
        legend('fz1','fz2', 'fy1', 'fy2')
        switch_peaks = switch_peaks(2:end)
        harea = area([switch_peaks(i), switch_peaks(i+1)], [10,10]);
        set( harea, 'FaceColor', 'y')
        alpha(.2)
        break
    end
end
 
% rang2=10000:10500; 
rang2=(baseline(ll):(baseline(ll)+500)); %GET THE BASELINE SO CAN GIVE A SHIFT, ????, LOOK INTO THIS, SHOULD WE PLOT NATURAL TO CHOOSE A RANGE??

shift1= median(fz1(rang2)); %USE THE ABOVE RANGE TO CALCULATE TO VALUE TO GIVE A SHIFT
shift2= median(fz2(rang2)); 
shift3= median(fy1(rang2)); 
shift4= median(fy2(rang2)); 

switch_val = switch_val(data_start:data_end);
foz1=-shift1+A.data(data_start:data_end,10); 
foz2=-shift2+A.data(data_start:data_end,11);   
foy1=-shift3+A.data(data_start:data_end,12); 
foy2=-shift4+A.data(data_start:data_end,13);  

foz1s=smooth(foz1(:),50); %uses a smoothing filter with a span of 50 (span=5=> yy(4) = (y(2) + y(3) + y(4) + y(5) + y(6))/5),(average of the input data from times t-arg1 to t+arg1, arg1=12.5 ms)
foz2s=smooth(foz2(:),50); 
foy1s=smooth(foy1(:),50); 
foy2s=smooth(foy2(:),50);


fig15=figure();   
 
plot( foz1s,'r' );   
hold on
plot(foz2s,'m' );  
hold on  
legend('fz1','fz2', 'fzr1', 'fzr2')



GF1=(foz1s); %GRIP FORCE IS AVERAGE OF THUMB AND INDEX, GF=foz2s; %
LF1=foy1s;   %LOAD FORCE IS SUMATION OF THUMB AND INDEX FORCES
 

GF2=(foz2s); %GRIP FORCE IS AVERAGE OF THUMB AND INDEX, GF=foz2s; %
LF2=foy2s;   %LOAD FORCE IS SUMATION OF THUMB AND INDEX FORCES
 

%Get derivitives numerically
step=25; 
for x=26:1:length(LF1)-26 
LFR1(x)=(LF1(x+step)-LF1(x-step))./(time(x+step)-time(x-step)); %get the first derivative (The slope at time t is calculated from the points in the time range t-arg1 to t+arg1, arg1=12.5 ms) 
end   

for x=26:1:length(GF1)-26 
GFR1(x)=(GF1(x+step)-GF1(x-step))./(time(x+step)-time(x-step)); %get the first derivative (The slope at time t is calculated from the points in the time range t-arg1 to t+arg1, arg1=12.5 ms) 
end 

for x=26:1:length(LF2)-26 
LFR2(x)=(LF2(x+step)-LF2(x-step))./(time(x+step)-time(x-step)); %get the first derivative (The slope at time t is calculated from the points in the time range t-arg1 to t+arg1, arg1=12.5 ms) 
end   

for x=26:1:length(GF2)-26 
GFR2(x)=(GF2(x+step)-GF2(x-step))./(time(x+step)-time(x-step)); %get the first derivative (The slope at time t is calculated from the points in the time range t-arg1 to t+arg1, arg1=12.5 ms) 
end 


plot( GFR1,'b' );   
hold on
plot(GFR2, 'k' );   
hold on
legend('fz1','fz2', 'fzr1', 'fzr2')



%Plot areas where sensor was down
switch_peaks_shift = switch_peaks*2000 - data_start;

for i=[1:2:length(switch_peaks_shift)]
    if i+1 > length(switch_peaks_shift)
        break
    end
    if switch_peaks_shift(i)<0 && switch_peaks_shift(i+1)<0
        continue
    end
    if switch_peaks_shift(i)<0
        switch_peaks_shift(i) = 1
    end
    harea = area([switch_peaks_shift(i), switch_peaks_shift(i+1)], [100,100]);
    set( harea, 'FaceColor', 'y')
    alpha(.2)
end


%auto LFR peaks are hte LFR peaks in the sensor down intervals
%auto GFR peaks are the GFR peaks in the sensor down intervals
%Also get area under curve in interval between GFR onset and sensor up. 
auto_LG = [];

switch_peaks = switch_peaks_shift/2000;
for i=[1:2:length(switch_peaks)]
    if (i+1 > length(switch_peaks)) || switch_peaks(i+1) > c_info15(1).Position(1,1)-data_start/2000
        break;
    end
    switch_start = switch_peaks(i);
    switch_end = switch_peaks(i+1);

    if switch_peaks(i) < 0 && switch_peaks(i+1) < 0
        continue %the manually indicated trial start is past this interval
    end
    if((switch_peaks(i+1) - switch_peaks(i))<0.4)
        continue %interval is suspiciously short
    end
    
    i1 = switch_start*2000;
    i2 = switch_end*2000;
    
    grip_onset1 = find(GFR1(i1:i2)<0,1,'last')+i1-1;
    grip_onset2 = find(GFR2(i1:i2)<0,1,'last')+i1-1;
    
    plot([grip_onset1, grip_onset1], [-100, 100], 'b--', 'LineWidth', 2)
    plot([grip_onset2, grip_onset2], [100, 100], 'k--', 'LineWidth', 2)
    harea=area([grip_onset2:i2], GF2(grip_onset2:i2));
    %harea = area([grip_onset2, i2], [100,100]);
    set( harea, 'FaceColor', 'r')
    alpha(.3)

    
    %get the area under the curve from grip_onset1 to i2 using trapz
    %trapezoidal integration
    ar1 = trapz(GF1(grip_onset1:i2))/2000;
    ar2 = trapz(GF2(grip_onset2: i2))/2000;

 
    [l1, loc] = max(LFR1(i1:i2));
    loc = loc-1 + i1;
    auto_LG = [auto_LG; max(LFR1(i1:i2)),max(GFR1(i1:i2)),max(LFR2(i1:i2)),max(GFR2(i1:i2)), ar1, ar2];
end

%write to file
cap_params =[str2num(capname)*ones(size(auto_LG,1), 1),str2num(weight)*ones(size(auto_LG,1), 1) auto_LG];
T_cap = array2table(cap_params, 'VariableNames', {'cap', 'weight','LFR_Y', 'GFR_Y', 'LFR_O', 'GFRO', 'area_Y', 'area_O'});
writetable(T_cap, strcat('auto_cap_', num2str(trial_id),'_lfr_gfr'));



clearvars -except filesforce params2
end
end
end


