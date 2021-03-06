%% Choose the Bacteria defined by ctrl+shift+x
% Revised 03-30-14 Zhen 
% Based on Molecule Catagory
clear
close all
clc
[FileName,PathName] = uigetfile('*.bin',...
    'Select *.bin File output by Insight3 ',...
    'MultiSelect', 'off');
cd(PathName);
Afname=char(FileName);
Molecule=ReadMasterMoleculeList(Afname);
plot(Molecule.xc,Molecule.yc,'.');
x=Molecule.xc;
y=Molecule.yc;
molecule_chosen=find((Molecule.c==1)|(Molecule.c==9));
figure;
plot(x(molecule_chosen),y(molecule_chosen),'.')
axis equal;
format = {...
    'single' [1 1] 'x'; ...
    'single' [1 1] 'y'; ...
    'single' [1 1] 'xc'; ...
    'single' [1 1] 'yc'; ...
    'single' [1 1] 'h'; ...
    'single' [1 1] 'a'; ...
    'single' [1 1] 'w'; ...
    'single' [1 1] 'phi'; ...
    'single' [1 1] 'ax'; ...
    'single' [1 1] 'bg'; ...
    'single' [1 1] 'i'; ...
    'int32' [1 1] 'c'; ...
    'int32' [1 1] 'density'; ...
    'int32' [1 1] 'frame'; ...
    'int32' [1 1] 'length'; ...
    'int32' [1 1] 'link'; ...
    'single' [1 1] 'z'; ...
    'single' [1 1] 'zc';};
for i=1:length(format)
     Molecule_chosen.(format{i,3})=Molecule.(format{i,3})(molecule_chosen,:);
end
WriteMoleculeList(Molecule_chosen,[FileName(1:end-4) '_ChosenbyInsight3_list.bin'])

%% chosen a specitic bacteria

% XLower=input('Please input x lower value');
% XUpper=input('Please input x upper value');
% YLower=input('Please input y lower value');
% YUpper=input('Please input y upper value');
% bacteria_chosen=find(x>XLower&y>YLower&x<XUpper&y<YUpper);
% plot(x(bacteria_chosen),y(bacteria_chosen),'.')


