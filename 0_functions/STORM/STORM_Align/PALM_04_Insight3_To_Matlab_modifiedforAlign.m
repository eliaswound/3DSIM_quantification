%% Write by Yujie Sun & Q. Peter Su on May 09 2013
%  Part I - Preview ~2000 Frame Molecule (Intensity to Width)
%  Part II - Convert Mol.List *.bin to *.dat file
%            Suitble for ST02_Merge_and_plotfiles.m
%                        ST07_precisionstat_3D.m

%% Input
%   1. The molecule list *.bin file auto-output by insight3
%      after analyzing dots, choose 'KeepMList'
%       Column  1 : Cas### - Number of All the HR molecules
%       Column  2 : X      - X in Pixel
%       Column  3 : Y      - Y in Pixel
%       Column  4 : Xc     - X in Pixel after Auto Drift Correction
%       Column  5 : Yc     - Y in Pixel after Auto Drift Correction
%       Column  6 : Height - Intensity/Height of Gaussian Fitting
%       Column  7 : Area   - Area of the Bottom of Gaussian Fitting
%       Column  8 : Width  - Width of the Gaussian Fitting
%       Column  9 : Phi    - 
%       Column 10 : Ax
%       Column 11 : BG     - Background
%       Column 12 : I
%       Column 13 : Frame  - Frame No.
%       Column 14 : Length
%       Column 15 : Link
%       Column 16 : Valid
%       Column 17 : Z      - Z in nm
%       Column 18 : Zc     - Z in nm after Correction

%% Output
%   1. *.dat file suitable for Merge_and_plotfiles.m
%       Column 01 : X coordinate in pixel
%       Column 02 : Y coordinate in pixel
%       Column 03 : Intensity (height of the Gaussian peak)
%       Column 04 : Ellipticity (Elp=a-b for Rahul Roy)
%       Column 05 : Width  - Width of the Gaussian Fitting
%       Column 06 : Width  - Width of the Gaussian Fitting    
%       Column 07 : Background
%       Column 11 : Frame No.
%
%   or
%
%   1. *.dat file suitable for DriftCorrect.m & precisionstat.m
%       Column  1 : X in um 
%       Column  2 : Y in um
%       Column  3 : Z in nm
%       Column  4 : Intensity/Height
%       Column  6 : Width in pixel
%       Column  7 : Width in pixel
%       Column  8 : Background
%       Column 12 : Frame No.




function ST21_Insight_to_Matlab_V2(Xpixel,Ypixel)
clc
close all;
[FileName,PathName] = uigetfile('*.bin',...
    'Select Drift Corrected Molecule List *.bin File output by Insight3',...
    'MultiSelect', 'off');
cd(PathName);
name=char(FileName);
% Import molecule *list.bin file with Zhuang's ReadMasterMoleculeList();
[MList2, memoryMap2] = ReadMasterMoleculeList(name);
Afname1=memoryMap2.Filename;
Afname='';
NameLength=length(Afname1);
i=1;
while Afname1(NameLength-i+1)~='\'
    Afname=[Afname1(NameLength-i+1) Afname];
    i=i+1;
end
width2=MList2.w;
height2=MList2.h;
disp('---');
dotsno=size(width2,1);
strout=['Totally, There are -' num2str(dotsno) '- Dots/Localizations.'];
disp(strout);
disp('---')
%%
disp('Output the data for Merge_and_plotfiles ? ');
disp('or DriftCorrect.m and precisionstat.m ? ');
%filejudge=input('Type in [m] for Merge_and_plotfiles.m, [p] for precisionstat.m - ','s');
filejudge='p';
%% for DriftCorrect and precisionstat.m
if filejudge=='p'
if nargin<1

%     Xpixel = input('Please input X pixel size (in nm)   - ');
%     Ypixel = input('Please input Y pixel size (in nm)   - ');   
Xpixel=160;
Ypixel=160;
end

disp('--')
disp('You Wanna Import the Auto-Drift-Corrected HR Molecules?');
%judge=input('Press c for Corrected Data, u for Un-Corrected Data. - ','s');
 judge='c';
if judge=='c'
    XYZt=[];
    XYZt(:,1) = MList2.xc*Xpixel/1000;   % X in um Corrected
    XYZt(:,2) = MList2.yc*Ypixel/1000;   % Y in um Corrected
    XYZt(:,3) = MList2.zc;               % Z in nm Corrected
    XYZt(:,4) = MList2.h;                % Intensity Height
    XYZt(:,6) = MList2.w;                % Width in pixel
    XYZt(:,7) = MList2.w;                % Width in pixel
    XYZt(:,8) = MList2.bg;               % Background
    XYZt(:,12)= MList2.frame;            % Frame No.
elseif judge=='u'
    XYZt=[];
    XYZt(:,1) = MList2.x*Xpixel/1000;    % X in um
    XYZt(:,2) = MList2.y*Ypixel/1000;    % Y in um
    XYZt(:,3) = MList2.z;                % Z in nm
    XYZt(:,4) = MList2.h;                % Intensity Height
    XYZt(:,6) = MList2.w;                % Width in pixel
    XYZt(:,7) = MList2.w;                % Width in pixel
    XYZt(:,8) = MList2.bg;               % Background
    XYZt(:,12)= MList2.frame;            % Frame No.
end

if judge=='c'
    outputfilename = Afname(1:end-4);
    outfilename  = strcat(outputfilename,'-Corr-Inst_to_p', '.dat')
    save(outfilename, 'XYZt', '-ascii', '-tabs');
elseif judge=='u'
    outputfilename = Afname(1:end-4);
    outfilename  = strcat(outputfilename,'-UnCorr-Inst_to_p', '.dat')
    save(outfilename, 'XYZt', '-ascii', '-tabs');
end
end

%% for Merge_and_plotfiles.m
if filejudge=='m'
disp('--')
disp('You Wanna Import the Auto-Drift-Corrected HR Molecules?');
judge=input('Press c for Corrected Data, u for Un-Corrected Data. - ','s');
if judge=='c'
    XYZt=[];
    XYZt(:,1) = MList2.xc;             % X in pixel Corrected
    XYZt(:,2) = MList2.yc;             % Y in pixel Corrected
    XYZt(:,3) = MList2.h;              % Intensity Height
    XYZt(:,4) = MList2.zc;             % Z in nm Corrected
    XYZt(:,5) = MList2.w;              % Width in pixel
    XYZt(:,6) = MList2.w;              % Width in pixel
    XYZt(:,7) = MList2.bg;             % Background
    XYZt(:,11)= MList2.frame;          % Frame No.
elseif judge=='u'
    XYZt=[];
    XYZt(:,1) = MList2.x;             % X in pixel Corrected
    XYZt(:,2) = MList2.y;             % Y in pixel Corrected
    XYZt(:,3) = MList2.h;              % Intensity Height
    XYZt(:,4) = MList2.z;             % Z in nm Corrected
    XYZt(:,5) = MList2.w;              % Width in pixel
    XYZt(:,6) = MList2.w;              % Width in pixel
    XYZt(:,7) = MList2.bg;             % Background
    XYZt(:,11)= MList2.frame;          % Frame No.
end

if judge=='c'
    outputfilename = Afname(1:end-4);
    outfilename  = strcat(outputfilename,'-Corr-Inst_to_M', '.dat')
    save(outfilename, 'XYZt', '-ascii', '-tabs');
elseif judge=='u'
    outputfilename = Afname(1:end-4);
    outfilename  = strcat(outputfilename,'-UnCorr-Inst_to_M', '.dat')
    save(outfilename, 'XYZt', '-ascii', '-tabs');
end
      
end


end
